//
//  ResidenceViewModel.swift
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

		var isShowingEditSheet = false
		var residenceToEdit: Residence?
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

		func showCreateResidenceSheet() {
			try? database.ensureDefaultProfile()
			residenceToEdit = nil
			isShowingEditSheet = true
		}

		func showEditResidenceSheet() {
			// Reload the latest data from database before editing
			if let selectedResidence {
				withErrorReporting {
					residenceToEdit = try database.write { db in
						try Residence.find(selectedResidence.id).fetchOne(db)
					}
				}
			}
			isShowingEditSheet = true
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
	}
}
