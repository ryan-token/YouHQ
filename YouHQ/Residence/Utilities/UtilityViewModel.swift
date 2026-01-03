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

		let utility: Utility
		var utilityTitle: String
		var utilityNotes: String {
			didSet {
				updateUtilityNotes()
			}
		}

		init(utility: Utility) {
			self.utility = utility

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

		func onAppear() {
			setInitialNotes()
		}

		// MARK: PRIVATE METHODS

		private func setInitialNotes() {
			utilityNotes = utility.notes
		}

		private func updateUtilityNotes() {
			withErrorReporting {
				try database.write { db in
					try Utility.find(utility.id)
						.update { $0.notes = utilityNotes }
						.execute(db)
				}
			}
		}
	}
}
