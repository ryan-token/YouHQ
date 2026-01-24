//
//  UtilityViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/19/26.
//

import SQLiteData
import SwiftUI

@Observable
class UtilityViewModel {
	@ObservationIgnored
	@Dependency(\.defaultDatabase) private var database

	@ObservationIgnored
	@FetchAll(Utility.none, animation: .default) var utilities

	var draftUtility: Utility?

	func load(for residenceID: UUID) async {
		_ = await withErrorReporting {
			try await $utilities.load(
				Utility
					.where { $0.residenceID.eq(residenceID) }
					.order { $0.type },
				animation: .default
			)
		}
	}

	func createDraft(for residenceID: UUID) -> Utility {
		Utility(
			id: UUID(),
			residenceID: residenceID,
			type: .electric,
			provider: "",
			accountNumber: "",
			approximateMonthlyCost: nil,
			backgroundColor: "blue",
			url: "",
			notes: ""
		)
	}

	func delete(_ utility: Utility) {
		do {
			try database.write { db in
				try Utility.find(utility.id)
					.delete()
					.execute(db)
			}

			Analytics.sendSignal(.residenceUtilityDeleted)
		} catch {
			Analytics.logError(id: .utilityDeleteFailed, message: error.localizedDescription)
			reportIssue(error)
		}
	}

	func updateBackgroundColor(_ color: Color, for utility: Utility) {
		withErrorReporting {
			try database.write { db in
				try Utility.find(utility.id)
					.update { $0.backgroundColor = color.databaseValue }
					.execute(db)
			}

			Analytics.sendSignal(.itemBackgroundColorChanged)
		}
	}
}
