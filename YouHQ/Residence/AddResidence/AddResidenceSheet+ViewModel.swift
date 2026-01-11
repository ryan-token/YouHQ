//
//  AddResidenceSheet+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/11/26.
//

import SQLiteData
import SwiftUI

extension AddResidenceSheet {
	@Observable
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		let profileID: UUID
		var type: ResidenceType = .apartment
		var isCurrent: Bool = true
		var street: String = ""
		var unit: String = ""
		var city: String = ""
		var state: String = ""
		var zipCode: String = ""
		var country: String = "USA"
		var moveInDate: Date?
		var moveOutDate: Date?
		var hasMoveOutDate: Bool = false
		var costType: CostType = .rent
		var monthlyCost: Double?

		var isValid: Bool {
			street.trimmingCharacters(in: .whitespaces).isNotEmpty
		}

		init(profileID: UUID) {
			self.profileID = profileID
		}

		func save() -> Residence? {
			var savedResidence: Residence?
			withErrorReporting {
				try database.write { db in
					let residenceID = UUID()
					try Residence.insert {
						Residence.Draft(
							id: residenceID,
							profileID: profileID,
							type: type,
							street: street,
							unit: unit,
							city: city,
							state: state,
							zipCode: zipCode,
							country: country,
							moveInDate: moveInDate,
							moveOutDate: hasMoveOutDate ? moveOutDate : nil,
							isCurrent: isCurrent,
							monthlyCost: monthlyCost,
							costType: costType,
							url: "",
							notes: ""
						)
					}
					.execute(db)
					savedResidence = try Residence.find(residenceID).fetchOne(db)
				}
			}
			return savedResidence
		}
	}
}
