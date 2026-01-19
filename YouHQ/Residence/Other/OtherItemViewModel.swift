//
//  OtherItemViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/19/26.
//

import SQLiteData
import SwiftUI

@Observable
class OtherItemViewModel {
	@ObservationIgnored
	@Dependency(\.defaultDatabase) private var database

	@ObservationIgnored
	@FetchAll(Other.none, animation: .default) var others

	var draftOther: Other?

	func load(for residenceID: UUID) async {
		_ = await withErrorReporting {
			try await $others.load(
				Other
					.where { $0.residenceID.eq(residenceID) }
					.order { $0.name },
				animation: .default
			)
		}
	}

	func createDraft(for residenceID: UUID, profileID: UUID) -> Other {
		Other(
			id: UUID(),
			profileID: profileID,
			residenceID: residenceID,
			name: "",
			otherDescription: "",
			monthlyCost: nil,
			backgroundColor: "gray",
			url: "",
			notes: ""
		)
	}

	func delete(_ other: Other) {
		withErrorReporting {
			try database.write { db in
				try Other.find(other.id)
					.delete()
					.execute(db)
			}
		}
	}
}
