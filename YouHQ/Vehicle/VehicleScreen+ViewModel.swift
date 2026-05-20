//
//  VehicleScreen+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import Sharing
import SQLiteData
import SwiftUI

extension VehicleScreen {
	@Observable
	class ViewModel: ProfileSelection {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) private var database

		@ObservationIgnored
		@FetchAll(ProfileShare.none, animation: .default) var profiles

		@ObservationIgnored
		@Shared(.appStorage(.selectedProfileIDKey)) var selectedProfileIDString = ""

		@ObservationIgnored
		@FetchAll(Vehicle.none, animation: .default) var vehicles

		// Child view models for entity-specific operations
		var insuranceViewModel = InsurancePolicyViewModel()
		var otherViewModel = OtherItemViewModel()
		var paintColorViewModel = PaintColorViewModel()
		var maintenanceViewModel = MaintenanceItemViewModel()

		@ObservationIgnored
		@Shared(.appStorage("selectedVehicleID")) var selectedVehicleID: String?

		init() {
			vehicleNotes = ""
		}

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
				vehicleNotes = selectedVehicle?.notes ?? ""

				// Load data for the new vehicle when ID changes
				if selectedVehicle?.id != oldValue?.id {
					loadDataTask?.cancel()
					loadDataTask = Task {
						await loadAllData()
					}
				}
			}
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
		var vehicleNotes: String

		private var notesDebounceTask: Task<Void, Never>?
		private var loadDataTask: Task<Void, Never>?

		// MARK: PROFILE FUNCTIONS

		func loadProfiles() async {
			_ = await withErrorReporting {
				try await $profiles.load(ProfileShare.allWithSyncMetadata, animation: .default)
			}
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
			await insuranceViewModel.loadVehicle(for: vehicleID)
			await maintenanceViewModel.loadVehicle(for: vehicleID)
			await paintColorViewModel.loadVehicle(for: vehicleID)
			await otherViewModel.loadVehicle(for: vehicleID)
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

		func showAddInsurancePolicySheet(sourceID: String = "addButton") {
			guard let vehicleID = selectedVehicle?.id,
				let profileID = selectedProfile?.profile.id
			else { return }
			sectionToEdit = .insurancePolicyDraft(
				insuranceViewModel.createVehicleDraft(for: vehicleID, profileID: profileID)
			)
			sheetTransitionSourceID = sourceID
			isShowingSectionEditSheet = true
		}

		func showAddMaintenanceItemSheet(sourceID: String = "addButton") {
			guard let vehicleID = selectedVehicle?.id else { return }
			sectionToEdit = .maintenanceItemDraft(maintenanceViewModel.createVehicleDraft(for: vehicleID))
			sheetTransitionSourceID = sourceID
			isShowingSectionEditSheet = true
		}

		func showAddPaintColorSheet(sourceID: String = "addButton") {
			guard let vehicleID = selectedVehicle?.id else { return }
			sectionToEdit = .paintColorDraft(paintColorViewModel.createVehicleDraft(for: vehicleID))
			sheetTransitionSourceID = sourceID
			isShowingSectionEditSheet = true
		}

		func showAddOtherSheet(sourceID: String = "addButton") {
			guard let vehicleID = selectedVehicle?.id,
				let profileID = selectedProfile?.profile.id
			else { return }
			sectionToEdit = .otherDraft(
				otherViewModel.createVehicleDraft(for: vehicleID, profileID: profileID)
			)
			sheetTransitionSourceID = sourceID
			isShowingSectionEditSheet = true
		}

	}
}
