//
//  ResidenceScreen+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 12/30/25.
//

import SQLiteData
import SwiftUI

extension ResidenceScreen {
	@Observable
	class ViewModel: ProfileSelection {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) private var database

		@ObservationIgnored
		@FetchAll(ProfileShare.none, animation: .default) var profiles

		@ObservationIgnored
		@AppStorage(.selectedProfileIDKey) var selectedProfileIDString: String = ""

		@ObservationIgnored
		@FetchAll(Residence.none, animation: .default) var residences

		// Child view models for entity-specific operations
		var utilityViewModel = UtilityViewModel()
		var insuranceViewModel = InsurancePolicyViewModel()
		var otherViewModel = OtherItemViewModel()
		var paintColorViewModel = PaintColorViewModel()
		var maintenanceViewModel = MaintenanceItemViewModel()

		@ObservationIgnored
		@AppStorage("selectedResidenceID") var selectedResidenceID: String?

		init() {
			residenceNotes = ""
		}

		var selectedProfile: ProfileShare? {
			getSelectedProfile()
		}

		var selectedResidence: Residence? {
			didSet {
				// Only persist to AppStorage if actually changed (prevent cycle)
				let newID = selectedResidence?.id.uuidString
				if newID != selectedResidenceID {
					selectedResidenceID = newID
					if oldValue != nil && selectedResidence != nil {
						Analytics.sendSignal(.residenceSwitched)
					}
				}
				residenceNotes = selectedResidence?.notes ?? ""

				// Load data for the new residence when ID changes (only for manual switching)
				if selectedResidence?.id != oldValue?.id, oldValue != nil {
					Task {
						await loadAllData()
					}
				}
			}
		}

		var hasMappableAddresses: Bool {
			residences.contains { $0.street.isNotEmpty && $0.city.isNotEmpty }
		}

		// used to determine whether we should show the paywall
		var residenceItemsCount: Int {
			let utilitiesCount = utilityViewModel.utilities.count
			let policiesCount = insuranceViewModel.insurancePolicies.count
			let otherCount = otherViewModel.others.count
			return utilitiesCount + policiesCount + otherCount
		}

		var backgroundColor: Color {
			Color(databaseValue: selectedResidence?.backgroundColor ?? "indigo")
		}

		var isShowingAddResidenceSheet = false
		var isShowingSectionEditSheet = false
		var sectionToEdit: EditableSection?
		var isNavigatingToMaintenanceItems = false
		var isNavigatingToPaintColors = false
		var residenceNotes: String

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
								isShared: $1.isShared.ifnull(false),
								metadata: $1
							)
						},
					animation: .default
				)
			}
		}

		// MARK: RESIDENCE FUNCTIONS

		private func loadResidences() async {
			guard let profileID = selectedProfile?.profile.id else { return }
			_ = await withErrorReporting {
				try await $residences.load(
					Residence
						.where { $0.profileID.eq(profileID) }
						.order { $0.street },
					animation: .default
				)
			}
		}

		func loadResidenceData() async {
			await loadResidences()
			await restoreSelection()
		}

		func handleProfileChange() async {
			await loadResidences()
			if !residences.isEmpty {
				await setSelectedResidence(to: residences.first!.id)
			} else {
				selectedResidence = nil
			}
		}

		private func loadAllData() async {
			guard let residenceID = selectedResidence?.id else { return }
			await utilityViewModel.load(for: residenceID)
			await insuranceViewModel.load(for: residenceID)
			await maintenanceViewModel.load(for: residenceID)
			await paintColorViewModel.load(for: residenceID)
			await otherViewModel.loadResidence(for: residenceID)
		}

		func restoreSelection() async {
			// Restore from AppStorage once
			if let selectedResidenceID,
				let selectedResidenceUUID = UUID(
					uuidString: selectedResidenceID
				)
			{
				await setSelectedResidence(to: selectedResidenceUUID)
			} else if selectedResidenceID == nil, !residences.isEmpty {
				await setSelectedResidence(to: residences.first!.id)
			}
		}

		private func setSelectedResidence(to residenceID: UUID) async {
			selectedResidence = residences.first(where: { $0.id == residenceID })
			// Wait for child data to load before returning
			await loadAllData()
		}

		func updateSelectedResidence() {
			if let selectedResidence {
				// We have a selected residence - update or replace it
				if let updatedResidence = residences.first(where: {
					$0.id == selectedResidence.id
				}) {
					// Residence still exists, update with latest data
					self.selectedResidence = updatedResidence
				} else {
					// Residence was deleted, select another one
					if let firstResidence = residences.first {
						self.selectedResidence = firstResidence
					} else {
						// No residences left
						self.selectedResidence = nil
					}
				}
			} else {
				// No residence selected - try to restore from AppStorage first
				if let selectedResidenceID,
					let uuid = UUID(uuidString: selectedResidenceID),
					let residence = residences.first(where: { $0.id == uuid })
				{
					self.selectedResidence = residence
				} else if let firstResidence = residences.first {
					// Fall back to first residence if no AppStorage value
					self.selectedResidence = firstResidence
				}
			}
		}

		func showCreateResidenceSheet() {
			isShowingAddResidenceSheet = true
		}

		func updateResidenceBackgroundColor(_ color: Color) {
			guard let selectedResidence else { return }
			withErrorReporting {
				try database.write { db in
					try Residence.find(selectedResidence.id)
						.update { $0.backgroundColor = color.databaseValue }
						.execute(db)
				}

				Analytics.sendSignal(.itemBackgroundColorChanged)
			}
		}

		// MARK: SHEET PRESENTATION

		func showAddUtilitySheet() {
			guard let residenceID = selectedResidence?.id else { return }
			utilityViewModel.draftUtility = utilityViewModel.createDraft(
				for: residenceID
			)
			sectionToEdit = .utilityDraft
			isShowingSectionEditSheet = true
		}

		func showAddInsurancePolicySheet() {
			guard let residenceID = selectedResidence?.id,
				let profileID = selectedProfile?.profile.id
			else { return }
			insuranceViewModel.draftInsurancePolicy =
				insuranceViewModel.createDraft(
					for: residenceID,
					profileID: profileID
				)
			sectionToEdit = .insurancePolicyDraft
			isShowingSectionEditSheet = true
		}

		func showAddMaintenanceItemSheet() {
			guard let residenceID = selectedResidence?.id else { return }
			maintenanceViewModel.draftMaintenanceItem =
				maintenanceViewModel.createDraft(for: residenceID)
			sectionToEdit = .maintenanceItemDraft
			isShowingSectionEditSheet = true
		}

		func showAddPaintColorSheet() {
			guard let residenceID = selectedResidence?.id else { return }
			paintColorViewModel.draftPaintColor =
				paintColorViewModel.createDraft(for: residenceID)
			sectionToEdit = .paintColorDraft
			isShowingSectionEditSheet = true
		}

		func showAddOtherSheet() {
			guard let residenceID = selectedResidence?.id,
				let profileID = selectedProfile?.profile.id
			else { return }
			otherViewModel.draftOther = otherViewModel.createResidenceDraft(
				for: residenceID,
				profileID: profileID
			)
			sectionToEdit = .otherDraft
			isShowingSectionEditSheet = true
		}

	}
}
