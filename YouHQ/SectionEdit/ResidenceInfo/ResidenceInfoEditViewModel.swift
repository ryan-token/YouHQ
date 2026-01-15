//
//  ResidenceInfoEditViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import SQLiteData
import SwiftUI

@Observable
final class ResidenceInfoEditViewModel: SectionEditViewModel {
	@ObservationIgnored
	@Dependency(\.defaultDatabase) var database

	let residence: Residence

	var residenceType: ResidenceType
	var isCurrent: Bool
	var street: String
	var unit: String
	var city: String
	var state: String
	var zipCode: String
	var country: String
	var moveInDate: Date?
	var moveOutDate: Date?
	var hasMoveOutDate: Bool
	var costType: CostType
	var monthlyCost: Double?
	var url: String
	var notes: String

	var title: String {
		"Edit Residence"
	}

	var isValid: Bool {
		street.trimmingCharacters(in: .whitespaces).isNotEmpty
	}

	let deleteConfirmationMessage = """
	Deleting this residence will also delete all utilities, insurance policies, maintenance items, and other items tied to it.
	"""

	init(residence: Residence) {
		self.residence = residence
		self.residenceType = residence.type
		self.isCurrent = residence.isCurrent
		self.street = residence.street
		self.unit = residence.unit
		self.city = residence.city
		self.state = residence.state
		self.zipCode = residence.zipCode
		self.country = residence.country
		self.moveInDate = residence.moveInDate
		self.moveOutDate = residence.moveOutDate
		self.hasMoveOutDate = residence.moveOutDate != nil
		self.costType = residence.costType
		self.monthlyCost = residence.monthlyCost
		self.url = residence.url
		self.notes = residence.notes
	}

	func save() {
		withErrorReporting {
			try database.write { db in
				try Residence.find(residence.id)
					.update {
						$0.type = residenceType
						$0.isCurrent = isCurrent
						$0.street = street
						$0.unit = unit
						$0.city = city
						$0.state = state
						$0.zipCode = zipCode
						$0.country = country
						$0.moveInDate = moveInDate
						$0.moveOutDate = hasMoveOutDate ? moveOutDate : nil
						$0.costType = costType
						$0.monthlyCost = monthlyCost
						$0.url = url
						$0.notes = notes
					}
					.execute(db)
			}
		}
	}

	func cancel() {
		// Don't delete residences on cancel
	}

	func delete() {
		withErrorReporting {
			try database.write { db in
				try Residence.find(residence.id)
					.delete()
					.execute(db)
			}
		}
	}
}
