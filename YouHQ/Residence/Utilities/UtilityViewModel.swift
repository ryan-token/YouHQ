//
//  UtilityViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/2/26.
//

import SQLiteData
import SwiftUI

extension UtilitySection {
	@Observable
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		@ObservationIgnored
		@FetchOne(Utility.none) var utility: Utility?

		let utilityID: UUID
		var utilityTitle: String
		var utilityNotes: String {
			didSet {
				updateUtilityNotes()
			}
		}

		init(utility: Utility) {
			self.utilityID = utility.id

			switch utility.type {
			case .electric:
				utilityTitle = "Electric"
			case .gas:
				utilityTitle = "Gas"
			case .water:
				utilityTitle = "Water"
			case .trash:
				utilityTitle = "Trash"
			case .sewage:
				utilityTitle = "Sewage"
			case .internet:
				utilityTitle = "Internet"
			case .other:
				utilityTitle = "Other"
			}

			self.utilityNotes = ""
		}

		func loadUtilityData() async {
			await loadUtility()
			setInitialUtilityNotes()
		}

		// MARK: PRIVATE METHODS

		private func loadUtility() async {
			_ = await withErrorReporting {
				try await $utility.load(
					Utility.where { $0.id.eq(utilityID) },
					animation: .default
				)
			}
		}

		private func setInitialUtilityNotes() {
			utilityNotes = utility?.notes ?? ""
		}

		private func updateUtilityNotes() {
			withErrorReporting {
				try database.write { db in
					try Utility.find(utilityID)
						.update { $0.notes = utilityNotes }
						.execute(db)
				}
			}
		}
	}
}
