//
//  ResidenceScreen+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 12/30/25.
//

import CloudKit
import SQLiteData
import SwiftUI

extension ResidenceScreen {
	@Observable
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) private var database

		@ObservationIgnored
		@Dependency(\.defaultSyncEngine) var syncEngine

		// Join: Get all profiles and whether they are shared or not
		@Selection
		struct ProfileShare { // swiftlint:disable:this nesting
			let profile: Profile
			let isShared: Bool
		}

		@ObservationIgnored
		@FetchAll(ProfileShare.none, animation: .default) var profiles

		@ObservationIgnored
		@FetchAll(Residence.none, animation: .default) var residences

		// Child view models for entity-specific operations
		var utilityViewModel = UtilityViewModel()
		var insuranceViewModel = InsurancePolicyViewModel()
		var maintenanceViewModel = MaintenanceItemViewModel()
		var paintColorViewModel = PaintColorViewModel()
		var otherViewModel = OtherItemViewModel()

		@ObservationIgnored
		@AppStorage("selectedResidenceID") var selectedResidenceID: String? {
			didSet {
				if selectedResidenceID != oldValue {
					Task {
						restoreSelection()
						await loadAllData()
					}
				}
			}
		}

		init() {
			residenceNotes = ""
		}

		// Sharable CloudKit data that can also drive a sheet to present a share interface
		var sharedRecord: SharedRecord?

		var selectedProfile: ProfileShare?

		var selectedResidence: Residence? {
			didSet {
				// Only persist to AppStorage if actually changed (prevent cycle)
				let newID = selectedResidence?.id.uuidString
				if newID != selectedResidenceID {
					selectedResidenceID = newID
				}
				residenceNotes = selectedResidence?.notes ?? ""
			}
		}

		// Computed property for background color
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
			setProfile(to: "Default")
			await loadResidences()
			restoreSelection()
			await loadAllData()
		}

		private func loadAllData() async {
			guard let residenceID = selectedResidence?.id else { return }
			await utilityViewModel.load(for: residenceID)
			await insuranceViewModel.load(for: residenceID)
			await maintenanceViewModel.load(for: residenceID)
			await paintColorViewModel.load(for: residenceID)
			await otherViewModel.load(for: residenceID)
		}

		func restoreSelection() {
			// Restore from AppStorage once
			if let selectedResidenceID,
				let selectedResidenceUUID = UUID(
					uuidString: selectedResidenceID
				)
			{
				setSelectedResidence(to: selectedResidenceUUID)
			} else if selectedResidenceID == nil, !residences.isEmpty {
				setSelectedResidence(to: residences.first!.id)
			}
		}

		private func setSelectedResidence(to residenceID: UUID) {
			selectedResidence = residences.first(where: { $0.id == residenceID }
			)
		}

		func shareResidenceTapped() async {
			if let selectedProfile {
				await withErrorReporting {
					sharedRecord = try await syncEngine.share(
						record: selectedProfile.profile
					) {
						$0[CKShare.SystemFieldKey.title] =
							selectedProfile.profile.name
						$0[CKShare.SystemFieldKey.thumbnailImageData] = nil
					}
				}
			}
		}

		func updateSelectedResidence() {
			guard let selectedResidence else { return }

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
		}

		func showCreateResidenceSheet() {
			try? database.ensureDefaultProfile()
			isShowingAddResidenceSheet = true
		}

		// MARK: RESIDENCE NOTES & COLOR

		func updateResidenceNotesDebounced() {
			// Cancel any pending update
			notesDebounceTask?.cancel()

			// Create new debounced task
			notesDebounceTask = Task {
				try? await Task.sleep(for: .seconds(0.5))

				// Check if task was cancelled
				guard !Task.isCancelled else { return }

				// Perform the update
				await updateResidenceNotes()
			}
		}

		private func updateResidenceNotes() async {
			guard let selectedResidence else { return }
			withErrorReporting {
				try database.write { db in
					try Residence.find(selectedResidence.id)
						.update { $0.notes = residenceNotes }
						.execute(db)
				}
			}
		}

		func updateResidenceBackgroundColor(_ color: Color) {
			guard let selectedResidence else { return }
			withErrorReporting {
				try database.write { db in
					try Residence.find(selectedResidence.id)
						.update { $0.backgroundColor = color.databaseValue }
						.execute(db)
				}
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
			otherViewModel.draftOther = otherViewModel.createDraft(
				for: residenceID,
				profileID: profileID
			)
			sectionToEdit = .otherDraft
			isShowingSectionEditSheet = true
		}

	}
}
