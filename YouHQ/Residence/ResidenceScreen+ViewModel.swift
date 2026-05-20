//
//  ResidenceScreen+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 12/30/25.
//

import Sharing
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
		@Shared(.appStorage(.selectedProfileIDKey)) var selectedProfileIDString = ""

		@ObservationIgnored
		@FetchAll(Residence.none, animation: .default) var residences

		// Child view models for entity-specific operations
		var utilityViewModel = UtilityViewModel()
		var insuranceViewModel = InsurancePolicyViewModel()
		var otherViewModel = OtherItemViewModel()
		var paintColorViewModel = PaintColorViewModel()
		var maintenanceViewModel = MaintenanceItemViewModel()

		@ObservationIgnored
		@Shared(.appStorage("selectedResidenceID")) var selectedResidenceID: String?

		init() {
			residenceNotes = ""
		}

		func setSelectedProfileIDString(_ value: String) {
			$selectedProfileIDString.withLock { $0 = value }
		}

		private func setSelectedResidenceID(_ value: String?) {
			$selectedResidenceID.withLock { $0 = value }
		}

		var selectedProfile: ProfileShare? {
			getSelectedProfile()
		}

		var selectedResidence: Residence? {
			didSet {
				// Only persist if actually changed (prevent cycle)
				let newID = selectedResidence?.id.uuidString
				if newID != selectedResidenceID {
					setSelectedResidenceID(newID)
					if oldValue != nil && selectedResidence != nil {
						Analytics.sendSignal(.residenceSwitched)
					}
				}
				residenceNotes = selectedResidence?.notes ?? ""

				// Load data for the new residence when ID changes
				if selectedResidence?.id != oldValue?.id {
					loadDataTask?.cancel()
					loadDataTask = Task {
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
		var sheetTransitionSourceID: String = "addButton"
		var isNavigatingToMaintenanceItems = false
		var isNavigatingToPaintColors = false
		var residenceNotes: String

		private var notesDebounceTask: Task<Void, Never>?
		private var loadDataTask: Task<Void, Never>?

		// MARK: PROFILE FUNCTIONS

		func loadProfiles() async {
			_ = await withErrorReporting {
				try await $profiles.load(ProfileShare.allWithSyncMetadata, animation: .default)
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
			if let first = residences.first {
				await setSelectedResidence(to: first.id)
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
			} else if selectedResidenceID == nil, let first = residences.first {
				await setSelectedResidence(to: first.id)
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
					self.selectedResidence = firstResidence
				}
			}
		}

		func showCreateResidenceSheet(sourceID: String = "addButton") {
			sheetTransitionSourceID = sourceID
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

		func showAddUtilitySheet(sourceID: String = "addButton") {
			guard let residenceID = selectedResidence?.id else { return }
			sectionToEdit = .utilityDraft(utilityViewModel.createDraft(for: residenceID))
			sheetTransitionSourceID = sourceID
			isShowingSectionEditSheet = true
		}

		func showAddInsurancePolicySheet(sourceID: String = "addButton") {
			guard let residenceID = selectedResidence?.id,
				let profileID = selectedProfile?.profile.id
			else { return }
			sectionToEdit = .insurancePolicyDraft(
				insuranceViewModel.createDraft(for: residenceID, profileID: profileID)
			)
			sheetTransitionSourceID = sourceID
			isShowingSectionEditSheet = true
		}

		func showAddMaintenanceItemSheet(sourceID: String = "addButton") {
			guard let residenceID = selectedResidence?.id else { return }
			sectionToEdit = .maintenanceItemDraft(maintenanceViewModel.createDraft(for: residenceID))
			sheetTransitionSourceID = sourceID
			isShowingSectionEditSheet = true
		}

		func showAddPaintColorSheet(sourceID: String = "addButton") {
			guard let residenceID = selectedResidence?.id else { return }
			sectionToEdit = .paintColorDraft(paintColorViewModel.createDraft(for: residenceID))
			sheetTransitionSourceID = sourceID
			isShowingSectionEditSheet = true
		}

		func showAddOtherSheet(sourceID: String = "addButton") {
			guard let residenceID = selectedResidence?.id,
				let profileID = selectedProfile?.profile.id
			else { return }
			sectionToEdit = .otherDraft(
				otherViewModel.createResidenceDraft(for: residenceID, profileID: profileID)
			)
			sheetTransitionSourceID = sourceID
			isShowingSectionEditSheet = true
		}

	}
}
