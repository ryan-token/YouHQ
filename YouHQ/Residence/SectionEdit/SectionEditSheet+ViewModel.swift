//
//  SectionEditSheet+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/10/26.
//

import SQLiteData
import SwiftUI

extension SectionEditSheet {
	@Observable
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		let section: EditableSection

		// Residence properties
		var residenceID: UUID?
		var residenceType: ResidenceType = .apartment
		var residenceIsCurrent: Bool = true
		var residenceStreet: String = ""
		var residenceUnit: String = ""
		var residenceCity: String = ""
		var residenceState: String = ""
		var residenceZipCode: String = ""
		var residenceCountry: String = "USA"
		var residenceMoveInDate: Date?
		var residenceMoveOutDate: Date?
		var residenceHasMoveOutDate: Bool = false
		var residenceCostType: CostType = .rent
		var residenceMonthlyCost: Double?
		var residenceURL: String = ""
		var residenceNotes: String = ""

		// Utility properties
		var utilityID: UUID?
		var utilityResidenceID: UUID?
		var utilityType: UtilityType = .electric
		var utilityProvider: String = ""
		var utilityAccountNumber: String = ""
		var utilityMonthlyCost: Double?
		var utilityURL: String = ""
		var utilityNotes: String = ""

		// Insurance properties
		var insuranceID: UUID?
		var insuranceProfileID: UUID?
		var insuranceResidenceID: UUID?
		var insuranceType: InsurancePolicyType = .health
		var insuranceProvider: String = ""
		var insurancePolicyNumber: String = ""
		var insuranceMonthlyCost: Double?
		var insuranceDeductible: Double?
		var insuranceCoverageAmount: Double?
		var insuranceRenewalDate: Date?
		var insuranceHasRenewalDate: Bool = false
		var insuranceURL: String = ""
		var insuranceNotes: String = ""

		// Other properties
		var otherID: UUID?
		var otherProfileID: UUID?
		var otherResidenceID: UUID?
		var otherName: String = ""
		var otherDescription: String = ""
		var otherURL: String = ""
		var otherNotes: String = ""

		var title: String {
			switch section {
			case .residenceInfo:
				"Edit Residence"
			case .utility(_, let isNew):
				isNew ? "Add Utility" : "Edit Utility"
			case .insurancePolicy(_, let isNew):
				isNew ? "Add Insurance" : "Edit Insurance"
			case .other(_, let isNew):
				isNew ? "Add Other" : "Edit Other"
			}
		}

		var isValid: Bool {
			switch section {
			case .residenceInfo:
				residenceStreet.trimmingCharacters(in: .whitespaces).isNotEmpty
			case .utility:
				true
			case .insurancePolicy:
				true
			case .other:
				otherName.trimmingCharacters(in: .whitespaces).isNotEmpty
			}
		}

		init(section: EditableSection) {
			self.section = section

			switch section {
			case .residenceInfo(let residence):
				residenceID = residence.id
				residenceType = residence.type
				residenceIsCurrent = residence.isCurrent
				residenceStreet = residence.street
				residenceUnit = residence.unit
				residenceCity = residence.city
				residenceState = residence.state
				residenceZipCode = residence.zipCode
				residenceCountry = residence.country
				residenceMoveInDate = residence.moveInDate
				residenceMoveOutDate = residence.moveOutDate
				residenceHasMoveOutDate = residence.moveOutDate != nil
				residenceCostType = residence.costType
				residenceMonthlyCost = residence.monthlyCost
				residenceURL = residence.url
				residenceNotes = residence.notes

			case .utility(let utility, _):
				utilityID = utility.id
				utilityResidenceID = utility.residenceID
				utilityType = utility.type
				utilityProvider = utility.provider
				utilityAccountNumber = utility.accountNumber
				utilityMonthlyCost = utility.approximateMonthlyCost
				utilityURL = utility.url
				utilityNotes = utility.notes

			case .insurancePolicy(let policy, _):
				insuranceID = policy.id
				insuranceProfileID = policy.profileID
				insuranceResidenceID = policy.residenceID
				insuranceType = policy.type
				insuranceProvider = policy.provider
				insurancePolicyNumber = policy.policyNumber
				insuranceMonthlyCost = policy.monthlyCost
				insuranceDeductible = policy.deductible
				insuranceCoverageAmount = policy.coverageAmount
				insuranceRenewalDate = policy.renewalDate
				insuranceHasRenewalDate = policy.renewalDate != nil
				insuranceURL = policy.url
				insuranceNotes = policy.notes

			case .other(let other, _):
				otherID = other.id
				otherProfileID = other.profileID
				otherResidenceID = other.residenceID
				otherName = other.name
				otherDescription = other.otherDescription
				otherURL = other.url
				otherNotes = other.notes
			}
		}

		func save() {
			switch section {
			case .residenceInfo:
				saveResidence()
			case .utility:
				saveUtility()
			case .insurancePolicy:
				saveInsurancePolicy()
			case .other:
				saveOther()
			}
		}

		func cancel() {
			// Delete the draft if it's a new item
			switch section {
			case .residenceInfo:
				break  // Don't delete residences on cancel
			case .utility(let utility, let isNew):
				if isNew {
					deleteUtility(utility.id)
				}
			case .insurancePolicy(let policy, let isNew):
				if isNew {
					deleteInsurancePolicy(policy.id)
				}
			case .other(let other, let isNew):
				if isNew {
					deleteOther(other.id)
				}
			}
		}

		private func deleteUtility(_ utilityID: UUID) {
			withErrorReporting {
				try database.write { db in
					try Utility.find(utilityID)
						.delete()
						.execute(db)
				}
			}
		}

		private func deleteInsurancePolicy(_ policyID: UUID) {
			withErrorReporting {
				try database.write { db in
					try InsurancePolicy.find(policyID)
						.delete()
						.execute(db)
				}
			}
		}

		private func deleteOther(_ otherID: UUID) {
			withErrorReporting {
				try database.write { db in
					try Other.find(otherID)
						.delete()
						.execute(db)
				}
			}
		}

		private func saveResidence() {
			guard let residenceID else { return }

			withErrorReporting {
				try database.write { db in
					try Residence.find(residenceID)
						.update {
							$0.type = residenceType
							$0.isCurrent = residenceIsCurrent
							$0.street = residenceStreet
							$0.unit = residenceUnit
							$0.city = residenceCity
							$0.state = residenceState
							$0.zipCode = residenceZipCode
							$0.country = residenceCountry
							$0.moveInDate = residenceMoveInDate
							$0.moveOutDate =
								residenceHasMoveOutDate
								? residenceMoveOutDate : nil
							$0.costType = residenceCostType
							$0.monthlyCost = residenceMonthlyCost
							$0.url = residenceURL
							$0.notes = residenceNotes
						}
						.execute(db)
				}
			}
		}

		private func saveUtility() {
			guard let utilityID else { return }

			withErrorReporting {
				try database.write { db in
					try Utility.find(utilityID)
						.update {
							$0.type = utilityType
							$0.provider = utilityProvider
							$0.accountNumber = utilityAccountNumber
							$0.approximateMonthlyCost = utilityMonthlyCost
							$0.url = utilityURL
							$0.notes = utilityNotes
						}
						.execute(db)
				}
			}
		}

		private func saveInsurancePolicy() {
			guard let insuranceID else { return }

			withErrorReporting {
				try database.write { db in
					try InsurancePolicy.find(insuranceID)
						.update {
							$0.type = insuranceType
							$0.provider = insuranceProvider
							$0.policyNumber = insurancePolicyNumber
							$0.monthlyCost = insuranceMonthlyCost
							$0.deductible = insuranceDeductible
							$0.coverageAmount = insuranceCoverageAmount
							$0.renewalDate =
								insuranceHasRenewalDate
								? insuranceRenewalDate : nil
							$0.url = insuranceURL
							$0.notes = insuranceNotes
						}
						.execute(db)
				}
			}
		}

		private func saveOther() {
			guard let otherID else { return }

			withErrorReporting {
				try database.write { db in
					try Other.find(otherID)
						.update {
							$0.name = otherName
							$0.otherDescription = otherDescription
							$0.url = otherURL
							$0.notes = otherNotes
						}
						.execute(db)
				}
			}
		}
	}
}
