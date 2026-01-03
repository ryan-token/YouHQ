//
//  ResidenceEditViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/2/26.
//

import SQLiteData
import SwiftUI

extension ResidenceEdit {
	@Observable
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		@ObservationIgnored
		@FetchAll(Utility.none) var utilities

		let profileID: UUID
		var residenceID: UUID?
		let isEditing: Bool
		var isShowingDeleteAlert: Bool = false
		var isShowingDeletionError: Bool = false

		var type: ResidenceType
		var street: String
		var unit: String
		var city: String
		var state: String
		var zipCode: String
		var country: String
		var moveInDate: Date?
		var moveOutDate: Date?
		var isCurrent: Bool
		var monthlyCost: Double?
		var costType: CostType
		var notes: String

		var isValid: Bool {
			street.trimmingCharacters(in: .whitespaces).isNotEmpty
				&& city.trimmingCharacters(in: .whitespaces).isNotEmpty
				&& state.trimmingCharacters(in: .whitespaces).isNotEmpty
		}

		init(residence: Residence?, profileID: UUID) {
			self.profileID = profileID

			if let residence {
				// editing an existing residence
				residenceID = residence.id
				isEditing = true
				type = residence.type
				street = residence.street
				unit = residence.unit
				city = residence.city
				state = residence.state
				zipCode = residence.zipCode
				country = residence.country
				moveInDate = residence.moveInDate
				moveOutDate = residence.moveOutDate
				isCurrent = residence.isCurrent
				monthlyCost = residence.monthlyCost
				costType = residence.costType
				notes = residence.notes
			} else {
				// creating a new residence
				residenceID = nil
				isEditing = false
				type = .apartment
				street = ""
				unit = ""
				city = ""
				state = ""
				zipCode = ""
				country = "USA"
				moveInDate = nil
				moveOutDate = nil
				isCurrent = true
				monthlyCost = nil
				costType = .rent
				notes = ""
			}

			if let residenceID {
				Task {
					await loadUtilities(for: residenceID)
				}
			}
		}

		func loadUtilities(for residenceID: UUID) async {
			_ = await withErrorReporting {
				try await $utilities.load(
					Utility.where { $0.residenceID.eq(residenceID) },
					animation: .default
				)
			}
		}

		func addUtility(type: UtilityType, residenceID: UUID) {
			withErrorReporting {
				try database.write { db in
					try Utility.insert {
						Utility.Draft(
							residenceID: residenceID,
							type: type
						)
					}
					.execute(db)
				}
			}
		}

		func deleteUtility(_ utility: Utility) {
			withErrorReporting {
				try database.write { db in
					try Utility.find(utility.id)
						.delete()
						.execute(db)
				}
			}
		}

		func save() -> Residence? {
			var savedResidence: Residence?
			withErrorReporting {
				try database.write { db in
					if let residenceID {
						// Update existing residence
						try Residence.find(residenceID)
							.update {
								$0.type = type
								$0.street = street
								$0.unit = unit
								$0.city = city
								$0.state = state
								$0.zipCode = zipCode
								$0.country = country
								$0.moveInDate = moveInDate
								$0.moveOutDate = moveOutDate
								$0.isCurrent = isCurrent
								$0.monthlyCost = monthlyCost
								$0.costType = costType
								$0.notes = notes
							}
							.execute(db)
						// Fetch the updated residence
						savedResidence = try Residence.find(residenceID)
							.fetchOne(db)
					} else {
						let id = UUID()
						try Residence.insert {
							Residence.Draft(
								id: id,
								profileID: profileID,
								type: type,
								street: street,
								unit: unit,
								city: city,
								state: state,
								zipCode: zipCode,
								country: country,
								moveInDate: moveInDate,
								moveOutDate: moveOutDate,
								isCurrent: isCurrent,
								monthlyCost: monthlyCost,
								costType: costType,
								notes: notes
							)
						}
						.execute(db)
						savedResidence = try Residence.find(id).fetchOne(db)
					}
				}
			}
			return savedResidence
		}

		func delete() -> Bool {
			var success: Bool = false

			withErrorReporting {
				if let residenceID {
					try database.write { db in
						try Residence.find(residenceID)
							.delete()
							.execute(db)

						success = true
					}
				} else {
					print("Error deleting residence: residenceID was nil")
					success = false
				}
			}

			return success
		}
	}
}
