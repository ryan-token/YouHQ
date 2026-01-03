//
//  ResidenceViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/2/26.
//

import SQLiteData
import SwiftUI

extension ResidenceInfo {
	@Observable
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		@ObservationIgnored
		@FetchAll(Utility.none) var utilities

		let residence: Residence

		var residenceNotes: String {
			didSet {
				updateResidenceNotes()
			}
		}

		init(residence: Residence) {
			self.residence = residence
			residenceNotes = residence.notes
		}

		func onAppear() async {
			await getUtilities()
		}

		// MARK: PRIVATE METHODS

		private func getUtilities() async {
			_ = await withErrorReporting {
				try await $utilities.load(
					Utility.where { $0.residenceID.eq(residence.id) },
					animation: .default
				)
			}
		}

		private func updateResidenceNotes() {
			withErrorReporting {
				try database.write { db in
					try Residence.find(residence.id)
						.update { $0.notes = residenceNotes }
						.execute(db)
				}
			}
		}
	}
}
