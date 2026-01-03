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
		@FetchAll private var profiles: [Profile]

		@ObservationIgnored
		@FetchAll(Residence.none, animation: .default) var residences // start empty, load via getResidences

		@ObservationIgnored
		@FetchAll(Utility.none, animation: .default) var utilities

		var residenceNotes: String {
			didSet {
				updateResidenceNotes()
			}
		}

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
		var selectedResidence: Residence? {
			didSet {
				Task { await loadResidenceData() }
			}
		}
		var isShowingEditSheet = false
		var residenceToEdit: Residence?

		func loadResidenceData() async {
			setProfileID(to: "Default")
			await loadResidences()

			if selectedResidence == nil && !residences.isEmpty {
				setSelectedResidence(to: residences.first!)
			}

			await loadUtilities()
			residenceNotes = selectedResidence?.notes ?? ""
		}

		func setProfileID(to profileName: String) {
			profileID = profiles.first(where: { $0.name == profileName })?.id
		}

		// MARK: RESIDENCE FUNCTIONS

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

		private func setSelectedResidence(to residence: Residence) {
			selectedResidence = residence
		}

		func showCreateResidenceSheet() {
			residenceToEdit = nil
			isShowingEditSheet = true
		}

		func showEditResidenceSheet() {
			residenceToEdit = selectedResidence
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

		private func updateResidenceNotes() {
			guard let selectedResidence else { return }
			withErrorReporting {
				try database.write { db in
					try Residence.find(selectedResidence.id)
						.update { $0.notes = residenceNotes }
						.execute(db)
				}
			}
		}
	}
}
