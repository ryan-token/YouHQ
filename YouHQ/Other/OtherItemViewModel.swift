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

	func loadResidence(for residenceID: UUID) async {
		_ = await withErrorReporting {
			try await $others.load(
				Other
					.where { $0.residenceID.eq(residenceID) }
					.order { $0.name },
				animation: .default
			)
		}
	}

	func loadVehicle(for vehicleID: UUID) async {
		_ = await withErrorReporting {
			try await $others.load(
				Other
					.where { $0.vehicleID.eq(vehicleID) }
					.order { $0.name },
				animation: .default
			)
		}
	}

	func loadCategory(for category: OtherCategory, profileID: UUID) async {
		_ = await withErrorReporting {
			try await $others.load(
				Other
					.where {
						$0.category.eq(category)
							.and($0.profileID.eq(profileID))
					}
					.order { $0.name },
				animation: .default
			)
		}
	}

	func createResidenceDraft(for residenceID: UUID, profileID: UUID) -> Other {
		Other(
			id: UUID(),
			profileID: profileID,
			residenceID: residenceID,
			vehicleID: nil,
			category: .homes,
			name: "",
			otherDescription: "",
			monthlyCost: nil,
			backgroundColor: "gray",
			url: "",
			notes: ""
		)
	}

	func createVehicleDraft(for vehicleID: UUID, profileID: UUID) -> Other {
		Other(
			id: UUID(),
			profileID: profileID,
			residenceID: nil,
			vehicleID: vehicleID,
			category: .vehicles,
			name: "",
			otherDescription: "",
			monthlyCost: nil,
			backgroundColor: "gray",
			url: "",
			notes: ""
		)
	}

	func createCategoryDraft(for category: OtherCategory, profileID: UUID) -> Other {
		Other(
			id: UUID(),
			profileID: profileID,
			residenceID: nil,
			vehicleID: nil,
			category: category,
			name: "",
			otherDescription: "",
			monthlyCost: nil,
			backgroundColor: "gray",
			url: "",
			notes: ""
		)
	}

	func delete(_ other: Other) {
		do {
			try database.write { db in
				try Other.find(other.id)
					.delete()
					.execute(db)
			}

			// Send appropriate analytics signal based on category
			switch other.category {
			case .homes:
				Analytics.sendSignal(.residenceOtherDeleted)
			case .vehicles:
				Analytics.sendSignal(.vehicleOtherDeleted)
			case .money:
				Analytics.sendSignal(.moneyOtherDeleted)
			case .media:
				Analytics.sendSignal(.moneyOtherDeleted)
			case .career:
				Analytics.sendSignal(.careerOtherDeleted)
			default:
				break
			}
		} catch {
			Analytics.logError(id: .otherDeleteFailed, message: error.localizedDescription)
			reportIssue(error)
		}
	}

	func updateBackgroundColor(_ color: Color, for other: Other) {
		withErrorReporting {
			try database.write { db in
				try Other.find(other.id)
					.update { $0.backgroundColor = color.databaseValue }
					.execute(db)
			}

			Analytics.sendSignal(.itemBackgroundColorChanged)
		}
	}
}
