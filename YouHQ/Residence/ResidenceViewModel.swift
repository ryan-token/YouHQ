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

		private var profileID: UUID?
		var isNewResidenceAlertPresented: Bool = false
		var newResidenceAddress: String = ""

		func onAppear() async {
			setProfileID(to: "Default")
			await getResidences()
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

		func createResidenceButtonTapped() {
			newResidenceAddress = ""
			isNewResidenceAlertPresented = true
		}

		func createResidence() {
			guard let profileID else { return }
			withErrorReporting {
				try database.write { db in
					try Residence.insert {
						Residence.Draft(
							profileID: profileID,
							street: newResidenceAddress
						)
					}
					.execute(db)
				}
			}
		}

		func deleteResidences(at offsets: IndexSet) {
			withErrorReporting {
				try database.write { db in
					try Residence.find(offsets.map { residences[$0].id })
						.delete()
						.execute(db)
				}
			}
		}
	}
}
