//
//  ResidencesViewModel.swift
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
		var selectedResidence: Residence?
		var isShowingEditSheet = false
		var residenceToEdit: Residence?

		func onAppear() async {
			setProfileID(to: "Default")
			await getResidences()

			if selectedResidence == nil && !residences.isEmpty {
				setSelectedResidence(to: residences.first!)
			}
		}

		func setProfileID(to profileName: String) {
			profileID = profiles.first(where: { $0.name == profileName })?.id
		}

		private func getResidences() async {
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
	}
}
