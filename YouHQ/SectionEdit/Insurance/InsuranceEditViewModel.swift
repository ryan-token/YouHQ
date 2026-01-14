//
//  InsuranceEditViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import SQLiteData
import SwiftUI

@Observable
final class InsuranceEditViewModel: SectionEditViewModel {
	@ObservationIgnored
	@Dependency(\.defaultDatabase) var database

	let policy: InsurancePolicy
	let isNew: Bool

	var type: InsurancePolicyType
	var provider: String
	var policyNumber: String
	var monthlyCost: Double?
	var deductible: Double?
	var coverageAmount: Double?
	var renewalDate: Date?
	var hasRenewalDate: Bool
	var url: String
	var notes: String

	var title: String {
		isNew ? "Add Insurance" : "Edit Insurance"
	}

	var isValid: Bool {
		true
	}

	init(policy: InsurancePolicy, isNew: Bool) {
		self.policy = policy
		self.isNew = isNew
		self.type = policy.type
		self.provider = policy.provider
		self.policyNumber = policy.policyNumber
		self.monthlyCost = policy.monthlyCost
		self.deductible = policy.deductible
		self.coverageAmount = policy.coverageAmount
		self.renewalDate = policy.renewalDate
		self.hasRenewalDate = policy.renewalDate != nil
		self.url = policy.url
		self.notes = policy.notes
	}

	func save() {
		withErrorReporting {
			try database.write { db in
				try InsurancePolicy.find(policy.id)
					.update {
						$0.type = type
						$0.provider = provider
						$0.policyNumber = policyNumber
						$0.monthlyCost = monthlyCost
						$0.deductible = deductible
						$0.coverageAmount = coverageAmount
						$0.renewalDate = hasRenewalDate ? renewalDate : nil
						$0.url = url
						$0.notes = notes
					}
					.execute(db)
			}
		}
	}

	func cancel() {
		if isNew {
			deletePolicy()
		}
	}

	private func deletePolicy() {
		withErrorReporting {
			try database.write { db in
				try InsurancePolicy.find(policy.id)
					.delete()
					.execute(db)
			}
		}
	}
}
