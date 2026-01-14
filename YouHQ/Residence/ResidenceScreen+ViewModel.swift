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
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) private var database

		@ObservationIgnored
		@FetchAll var profiles: [Profile]

		@ObservationIgnored
		@FetchAll(Residence.none, animation: .default) var residences  // start empty, load via getResidences

		@ObservationIgnored
		@FetchAll(Utility.none, animation: .default) var utilities

		@ObservationIgnored
		@FetchAll(InsurancePolicy.none, animation: .default)
		var insurancePolicies

		@ObservationIgnored
		@FetchAll(MaintenanceItem.none, animation: .default)
		var maintenanceItems

		@ObservationIgnored
		@FetchAll(Other.none, animation: .default) var others

		init() {
			residenceNotes = ""
		}

		// MARK: EXAMPLE JOIN - for each profile, how many residences are there?
		//		@Selection struct Row {
		//			let profile: Profile
		//			let residenceCount: Int
		//		}
		//
		//		@ObservationIgnored
		//		@FetchAll(
		//			Profile
		//				.group(by: \.id)
		//				.leftJoin(Residence.all) { $0.id.eq($1.profileID) }
		//				.select { Row.Columns.init(profile: $0, residenceCount: $1.count()) }
		//		) var rows

		var profileID: UUID?

		@ObservationIgnored
		@AppStorage("selectedResidenceID") var selectedResidenceID: String? {
			didSet {
				if selectedResidenceID != oldValue {
					Task { await loadResidenceData() }
				}
			}
		}

		var selectedResidence: Residence? {
			didSet {
				selectedResidenceID = selectedResidence?.id.uuidString
				backgroundColor = Color(
					databaseValue: selectedResidence?.backgroundColor
						?? "indigo"
				)
				residenceNotes = selectedResidence?.notes ?? ""
			}
		}

		var isShowingAddResidenceSheet = false
		var isShowingSectionEditSheet = false
		var isNavigatingToMaintenanceItems = false
		var sectionToEdit: EditableSection?
		var showingAddMoreDialog = false
		var backgroundColor: Color = .indigo
		var residenceNotes: String {
			didSet {
				updateResidenceNotes()
			}
		}

		// MARK: PROFILE FUNCTIONS

		private func setProfile(to profileName: String) {
			profileID = profiles.first(where: { $0.name == profileName })?.id
		}

		// MARK: RESIDENCE FUNCTIONS

		func loadResidenceData() async {
			setProfile(to: "Default")
			await loadResidences()

			if let selectedResidenceID,
				let selectedResidenceUUID = UUID(
					uuidString: selectedResidenceID
				)
			{
				setSelectedResidence(to: selectedResidenceUUID)
			} else if selectedResidenceID == nil && !residences.isEmpty {
				setSelectedResidence(to: residences.first!.id)
			}

			await loadUtilities()
			await loadInsurancePolicies()
			await loadMaintenanceItems()
			await loadOthers()
			residenceNotes = selectedResidence?.notes ?? ""
		}

		private func loadResidences() async {
			guard let profileID else { return }
			_ = await withErrorReporting {
				try await $residences.load(
					Residence
						.where { $0.profileID.eq(profileID) }
						.order { $0.street },
					animation: .default
				)
			}
		}

		private func setSelectedResidence(to residenceID: UUID) {
			selectedResidence = residences.first(where: { $0.id == residenceID }
			)
		}

		func updateSelectedResidence() {
			guard let selectedResidence,
				let updatedResidence = residences.first(where: {
					$0.id == selectedResidence.id
				})
			else { return }

			self.selectedResidence = updatedResidence
		}

		func showCreateResidenceSheet() {
			try? database.ensureDefaultProfile()
			isShowingAddResidenceSheet = true
		}

		// MARK: UTILITY FUNCTIONS

		private func loadUtilities() async {
			guard let selectedResidence else { return }
			_ = await withErrorReporting {
				try await $utilities.load(
					Utility
						.where { $0.residenceID.eq(selectedResidence.id) }
						.order { $0.type },
					animation: .default
				)
			}
		}

		// MARK: INSURANCE FUNCTIONS

		private func loadInsurancePolicies() async {
			guard let selectedResidence else { return }
			_ = await withErrorReporting {
				try await $insurancePolicies.load(
					InsurancePolicy
						.where { $0.residenceID.eq(selectedResidence.id) }
						.order { $0.type },
					animation: .default
				)
			}
		}

		private func updateResidenceNotes() {
			guard let selectedResidence else { return }
			print("setting db notes to \(residenceNotes)")
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

		func showAddUtilitySheet() {
			guard let selectedResidence else { return }
			// Create a temporary utility in the database that will be deleted if cancelled
			var createdUtility: Utility?
			withErrorReporting {
				try database.write { db in
					let utilityID = UUID()
					try Utility.insert {
						Utility.Draft(
							id: utilityID,
							residenceID: selectedResidence.id,
							type: .electric
						)
					}
					.execute(db)
					createdUtility = try Utility.find(utilityID).fetchOne(db)
				}
			}
			if let createdUtility {
				sectionToEdit = .utility(createdUtility, isNew: true)
				isShowingSectionEditSheet = true
			}
		}

		func showAddInsurancePolicySheet() {
			guard let selectedResidence, let profileID else { return }
			// Create a temporary policy in the database that will be deleted if cancelled
			var createdPolicy: InsurancePolicy?
			withErrorReporting {
				try database.write { db in
					let policyID = UUID()
					// Use .renters as default since it requires residenceID
					try InsurancePolicy.insert {
						InsurancePolicy.Draft(
							id: policyID,
							profileID: profileID,
							residenceID: selectedResidence.id,
							type: .renters
						)
					}
					.execute(db)
					createdPolicy = try InsurancePolicy.find(policyID).fetchOne(
						db
					)
				}
			}
			if let createdPolicy {
				sectionToEdit = .insurancePolicy(createdPolicy, isNew: true)
				isShowingSectionEditSheet = true
			}
		}

		func deleteUtility(_ utility: Utility) {
			withErrorReporting {
				try database.write { db in
					try Utility.find(utility.id)
						.delete()
						.execute(db)
				}
			}
		}

		func deleteInsurancePolicy(_ policy: InsurancePolicy) {
			withErrorReporting {
				try database.write { db in
					try InsurancePolicy.find(policy.id)
						.delete()
						.execute(db)
				}
			}
		}

		// MARK: MAINTENANCE ITEM FUNCTIONS

		private func loadMaintenanceItems() async {
			guard let selectedResidence else { return }
			_ = await withErrorReporting {
				try await $maintenanceItems.load(
					MaintenanceItem
						.where { $0.residenceID.eq(selectedResidence.id) }
						.order { $0.name },
					animation: .default
				)
			}
		}

		func showAddMaintenanceItemSheet() {
			guard let selectedResidence else { return }
			// Create a temporary maintenance item in the database that will be deleted if cancelled
			var createdItem: MaintenanceItem?
			withErrorReporting {
				try database.write { db in
					let itemID = UUID()
					try MaintenanceItem.insert {
						MaintenanceItem.Draft(
							id: itemID,
							residenceID: selectedResidence.id,
							vehicleID: nil
						)
					}
					.execute(db)
					createdItem = try MaintenanceItem.find(itemID).fetchOne(db)
				}
			}
			if let createdItem {
				sectionToEdit = .maintenanceItem(createdItem, isNew: true)
				isShowingSectionEditSheet = true
			}
		}

		func deleteMaintenanceItem(_ item: MaintenanceItem) {
			withErrorReporting {
				try database.write { db in
					try MaintenanceItem.find(item.id)
						.delete()
						.execute(db)
				}
			}
		}

		func completeMaintenanceItem(_ item: MaintenanceItem) {
			withErrorReporting {
				try database.write { db in
					let completedAt = Date()
					let nextDue = item.calculateNextDueDate(from: completedAt)

					// Create completion record
					try MaintenanceCompletion.insert {
						MaintenanceCompletion.Draft(
							id: UUID(),
							maintenanceItemID: item.id,
							completedAt: completedAt,
							notes: ""
						)
					}
					.execute(db)

					// Update item
					try MaintenanceItem.find(item.id)
						.update {
							$0.lastCompletedAt = completedAt
							$0.nextDueDate = nextDue
						}
						.execute(db)
				}
			}
		}

		// MARK: OTHER FUNCTIONS

		private func loadOthers() async {
			guard let selectedResidence else { return }
			_ = await withErrorReporting {
				try await $others.load(
					Other
						.where { $0.residenceID.eq(selectedResidence.id) }
						.order { $0.name },
					animation: .default
				)
			}
		}

		func showAddOtherSheet() {
			guard let selectedResidence, let profileID else { return }
			// Create a temporary other in the database that will be deleted if cancelled
			var createdOther: Other?
			withErrorReporting {
				try database.write { db in
					let otherID = UUID()
					try Other.insert {
						Other.Draft(
							id: otherID,
							profileID: profileID,
							residenceID: selectedResidence.id
						)
					}
					.execute(db)
					createdOther = try Other.find(otherID).fetchOne(db)
				}
			}
			if let createdOther {
				sectionToEdit = .other(createdOther, isNew: true)
				isShowingSectionEditSheet = true
			}
		}

		func deleteOther(_ other: Other) {
			withErrorReporting {
				try database.write { db in
					try Other.find(other.id)
						.delete()
						.execute(db)
				}
			}
		}
	}
}
