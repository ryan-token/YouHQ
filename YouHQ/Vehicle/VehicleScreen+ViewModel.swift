//
//  VehicleScreen+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

extension VehicleScreen {
	@Observable
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) private var database

		@ObservationIgnored
		@FetchAll(ProfileShare.none, animation: .default) var profiles

		@ObservationIgnored
		@FetchAll(Vehicle.none, animation: .default) var vehicles

		// Child view models for entity-specific operations
		var insuranceViewModel = InsurancePolicyViewModel()
		var otherViewModel = OtherItemViewModel()
		var paintColorViewModel = PaintColorViewModel()
		var maintenanceViewModel = MaintenanceItemViewModel()

		@ObservationIgnored
		@AppStorage("selectedVehicleID") var selectedVehicleID: String?

		init() {
			vehicleNotes = ""
		}

		var selectedProfile: ProfileShare?

		var selectedVehicle: Vehicle? {
			didSet {
				// Only persist to AppStorage if actually changed (prevent cycle)
				let newID = selectedVehicle?.id.uuidString
				if newID != selectedVehicleID {
					selectedVehicleID = newID
					if oldValue != nil && selectedVehicle != nil {
						Analytics.sendSignal(.vehicleSwitched)
					}
				}
				vehicleNotes = selectedVehicle?.notes ?? ""

				// Load data for the new vehicle when ID changes (only for manual switching)
				if selectedVehicle?.id != oldValue?.id, oldValue != nil {
					Task {
						await loadAllData()
					}
				}
			}
		}

		// Computed property for background color
		var backgroundColor: Color {
			Color(databaseValue: selectedVehicle?.backgroundColor ?? "teal")
		}

		var isShowingAddVehicleSheet = false
		var isShowingSectionEditSheet = false
		var sectionToEdit: EditableSection?
		var isNavigatingToMaintenanceItems = false
		var isNavigatingToPaintColors = false
		var vehicleNotes: String

		// Task for debouncing notes updates
		private var notesDebounceTask: Task<Void, Never>?

		// MARK: PROFILE FUNCTIONS

		func loadProfiles() async {
			_ = await withErrorReporting {
				try await $profiles.load(
					Profile
						.group(by: \.id)
						.leftJoin(SyncMetadata.all) {
							$0.syncMetadataID.eq($1.id)
						}
						.select {
							ProfileShare.Columns(
								profile: $0,
								isShared: $1.isShared.ifnull(false)
							)
						},
					animation: .default
				)
			}
		}

		private func setProfile(to profileName: String) {
			selectedProfile = profiles.first(where: {
				$0.profile.name == profileName
			})
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
			setProfile(to: "Default")
			await loadVehicles()
			await restoreSelection()
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
			} else if selectedVehicleID == nil, !vehicles.isEmpty {
				await setSelectedVehicle(to: vehicles.first!.id)
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
					// Fall back to first vehicle if no AppStorage value
					self.selectedVehicle = firstVehicle
				}
			}
		}

		func showCreateVehicleSheet() {
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

		func showAddInsurancePolicySheet() {
			guard let vehicleID = selectedVehicle?.id,
				let profileID = selectedProfile?.profile.id
			else { return }
			insuranceViewModel.draftInsurancePolicy =
				insuranceViewModel.createVehicleDraft(
					for: vehicleID,
					profileID: profileID
				)
			sectionToEdit = .insurancePolicyDraft
			isShowingSectionEditSheet = true
		}

		func showAddMaintenanceItemSheet() {
			guard let vehicleID = selectedVehicle?.id else { return }
			maintenanceViewModel.draftMaintenanceItem =
				maintenanceViewModel.createVehicleDraft(for: vehicleID)
			sectionToEdit = .maintenanceItemDraft
			isShowingSectionEditSheet = true
		}

		func showAddPaintColorSheet() {
			guard let vehicleID = selectedVehicle?.id else { return }
			paintColorViewModel.draftPaintColor =
				paintColorViewModel.createVehicleDraft(for: vehicleID)
			sectionToEdit = .paintColorDraft
			isShowingSectionEditSheet = true
		}

		func showAddOtherSheet() {
			guard let vehicleID = selectedVehicle?.id,
				let profileID = selectedProfile?.profile.id
			else { return }
			otherViewModel.draftOther = otherViewModel.createVehicleDraft(
				for: vehicleID,
				profileID: profileID
			)
			sectionToEdit = .otherDraft
			isShowingSectionEditSheet = true
		}

	}
}
