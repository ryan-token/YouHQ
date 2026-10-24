//
//  VehicleScreen+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import Sharing
import SwiftUI

extension VehicleScreen {
	@Observable
	class ViewModel: ProfileSelection, InitialLoadTracking {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) private var database

		@ObservationIgnored
		@FetchAll(ProfileShare.none, animation: .default) var profiles

		@ObservationIgnored
		@Shared(.appStorage(.selectedProfileIDKey)) var selectedProfileIDString = ""

		@ObservationIgnored
		@FetchAll(Vehicle.none, animation: .default) var vehicles

		// Child view models for entity-specific operations
		let insuranceViewModel = InsurancePolicyViewModel()
		let otherViewModel = OtherItemViewModel()
		let paintColorViewModel = PaintColorViewModel()
		let maintenanceViewModel = MaintenanceItemViewModel()

		@ObservationIgnored
		@Shared(.appStorage("selectedVehicleID")) var selectedVehicleID: String?

		init() {}

		func setSelectedProfileIDString(_ value: String) {
			$selectedProfileIDString.withLock { $0 = value }
		}

		private func setSelectedVehicleID(_ value: String?) {
			$selectedVehicleID.withLock { $0 = value }
		}

		var selectedProfile: ProfileShare? {
			getSelectedProfile()
		}

		var selectedVehicle: Vehicle? {
			didSet {
				// Only persist if actually changed (prevent cycle)
				let newID = selectedVehicle?.id.uuidString
				if newID != selectedVehicleID {
					setSelectedVehicleID(newID)
					if oldValue != nil && selectedVehicle != nil {
						Analytics.sendSignal(.vehicleSwitched)
					}
				}
				// Load data for the new vehicle when ID changes
				if selectedVehicle?.id != oldValue?.id {
					loadDataTask?.cancel()
					loadDataTask = Task {
						await loadAllData()
					}
				}
			}
		}

		/// The selected vehicle's ID, for binding vehicle pickers. Setting an ID that
		/// doesn't match a loaded vehicle leaves the selection unchanged.
		var pickerSelectedVehicleID: Vehicle.ID? {
			get { selectedVehicle?.id }
			set {
				if let vehicle = vehicles.first(where: { $0.id == newValue }) {
					selectedVehicle = vehicle
				}
			}
		}

		/// The persisted selection as a UUID, used to build the pushed vehicle screens.
		var persistedSelectedVehicleUUID: UUID? {
			selectedVehicleID.flatMap { UUID(uuidString: $0) }
		}

		/// The selected vehicle's name, or "Vehicles" when none is selected.
		var navigationTitle: String {
			selectedVehicle?.displayName ?? "Vehicles"
		}

		// used to determine whether we should show the paywall
		var vehicleItemsCount: Int {
			let policiesCount = insuranceViewModel.insurancePolicies.count
			let otherCount = otherViewModel.others.count
			return policiesCount + otherCount
		}

		var backgroundColor: Color {
			Color(databaseValue: selectedVehicle?.backgroundColor ?? "teal")
		}

		var isShowingAddVehicleSheet = false
		var isShowingSectionEditSheet = false
		var sectionToEdit: EditableSection?
		var sheetTransitionSourceID: String = "addButton"
		var isNavigatingToMaintenanceItems = false
		var isNavigatingToPaintColors = false
		var hasCompletedInitialLoad = false

		private var loadDataTask: Task<Void, Never>?

		// MARK: PROFILE FUNCTIONS

		func loadProfiles() async {
			await ProfileShare.reload(into: $profiles)
		}

		// MARK: VEHICLE FUNCTIONS

		private func loadVehicles() async {
			guard let profileID = selectedProfile?.profile.id else { return }
			_ = await withErrorReporting {
				try await $vehicles.load(
					Vehicle
						.where { $0.profileID.eq(profileID) }
						.order { $0.make },
					animation: .default
				)
			}
		}

		func loadVehicleData() async {
			await loadVehicles()
			await restoreSelection()
			await markInitialLoadComplete()
		}

		func handleProfileChange() async {
			await loadVehicles()
			if let first = vehicles.first {
				await setSelectedVehicle(to: first.id)
			} else {
				selectedVehicle = nil
			}
		}

		private func loadAllData() async {
			guard let vehicleID = selectedVehicle?.id else { return }
			async let insurance: Void = insuranceViewModel.loadVehicle(for: vehicleID)
			async let maintenance: Void = maintenanceViewModel.loadVehicle(for: vehicleID)
			async let paintColors: Void = paintColorViewModel.loadVehicle(for: vehicleID)
			async let others: Void = otherViewModel.loadVehicle(for: vehicleID)
			_ = await (insurance, maintenance, paintColors, others)
		}

		func restoreSelection() async {
			// Restore from AppStorage once
			if let selectedVehicleID,
				let selectedVehicleUUID = UUID(
					uuidString: selectedVehicleID
				)
			{
				await setSelectedVehicle(to: selectedVehicleUUID)
			} else if selectedVehicleID == nil, let first = vehicles.first {
				await setSelectedVehicle(to: first.id)
			}
		}

		private func setSelectedVehicle(to vehicleID: UUID) async {
			selectedVehicle = vehicles.first(where: { $0.id == vehicleID })
			// Wait for child data to load before returning
			await loadAllData()
		}

		func updateSelectedVehicle() {
			if let selectedVehicle {
				// We have a selected vehicle - update or replace it
				if let updatedVehicle = vehicles.first(where: {
					$0.id == selectedVehicle.id
				}) {
					// Vehicle still exists, update with latest data
					self.selectedVehicle = updatedVehicle
				} else {
					// Vehicle was deleted, select another one
					if let firstVehicle = vehicles.first {
						self.selectedVehicle = firstVehicle
					} else {
						// No vehicles left
						self.selectedVehicle = nil
					}
				}
			} else {
				// No vehicle selected - try to restore from AppStorage first
				if let selectedVehicleID,
					let uuid = UUID(uuidString: selectedVehicleID),
					let vehicle = vehicles.first(where: { $0.id == uuid })
				{
					self.selectedVehicle = vehicle
				} else if let firstVehicle = vehicles.first {
					self.selectedVehicle = firstVehicle
				}
			}
		}

		func showCreateVehicleSheet(sourceID: String = "addButton") {
			sheetTransitionSourceID = sourceID
			isShowingAddVehicleSheet = true
		}

		func updateVehicleBackgroundColor(_ color: Color) {
			guard let selectedVehicle else { return }
			withErrorReporting {
				try database.write { db in
					try Vehicle.find(selectedVehicle.id)
						.update { $0.backgroundColor = color.databaseValue }
						.execute(db)
				}

				Analytics.sendSignal(.itemBackgroundColorChanged)
			}
		}

		// MARK: SHEET PRESENTATION

		func showSectionEditSheet(for section: EditableSection, sourceID: String) {
			sectionToEdit = section
			sheetTransitionSourceID = sourceID
			isShowingSectionEditSheet = true
		}

		func showAddInsurancePolicySheet(sourceID: String = "addButton") {
			guard let vehicleID = selectedVehicle?.id,
				let profileID = selectedProfile?.profile.id
			else { return }
			showSectionEditSheet(
				for: .insurancePolicyDraft(
					insuranceViewModel.createVehicleDraft(for: vehicleID, profileID: profileID)
				),
				sourceID: sourceID
			)
		}

		func showAddMaintenanceItemSheet(sourceID: String = "addButton") {
			guard let vehicleID = selectedVehicle?.id else { return }
			showSectionEditSheet(
				for: .maintenanceItemDraft(maintenanceViewModel.createVehicleDraft(for: vehicleID)),
				sourceID: sourceID
			)
		}

		func showAddPaintColorSheet(sourceID: String = "addButton") {
			guard let vehicleID = selectedVehicle?.id else { return }
			showSectionEditSheet(
				for: .paintColorDraft(paintColorViewModel.createVehicleDraft(for: vehicleID)),
				sourceID: sourceID
			)
		}

		func showAddOtherSheet(sourceID: String = "addButton") {
			guard let vehicleID = selectedVehicle?.id,
				let profileID = selectedProfile?.profile.id
			else { return }
			showSectionEditSheet(
				for: .otherDraft(
					otherViewModel.createVehicleDraft(for: vehicleID, profileID: profileID)
				),
				sourceID: sourceID
			)
		}

	}
}
