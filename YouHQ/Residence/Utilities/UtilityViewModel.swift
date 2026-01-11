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
		var backgroundColor: Color = .blue
		var utilityNotes: String {
			didSet {
				updateUtilityNotes()
			}
		}

		var utilityTitle: String {
			guard let utility else { return "Utility" }
			return utility.type.rawValue
		}

		init(utility: Utility) {
			self.utilityID = utility.id
			self.utilityNotes = ""
		}

		func loadUtilityData() async {
			await loadUtility()
			setInitialUtilityNotes()
			setInitialBackgroundColor()
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

		private func setInitialBackgroundColor() {
			backgroundColor = Color(
				databaseValue: utility?.backgroundColor ?? "blue"
			)
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

		func updateUtilityBackgroundColor(_ color: Color) {
			withErrorReporting {
				try database.write { db in
					try Utility.find(utilityID)
						.update { $0.backgroundColor = color.databaseValue }
						.execute(db)
				}
			}
		}
	}
}
