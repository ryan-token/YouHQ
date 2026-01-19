//
//  InsurancePolicyViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/19/26.
//

import SQLiteData
import SwiftUI

@Observable
class InsurancePolicyViewModel {
	@ObservationIgnored
	@Dependency(\.defaultDatabase) private var database

	@ObservationIgnored
	@FetchAll(InsurancePolicy.none, animation: .default) var insurancePolicies

	var draftInsurancePolicy: InsurancePolicy?

	func load(for residenceID: UUID) async {
		_ = await withErrorReporting {
			try await $insurancePolicies.load(
				InsurancePolicy
					.where { $0.residenceID.eq(residenceID) }
					.order { $0.type },
				animation: .default
			)
		}
	}

	func createDraft(for residenceID: UUID, profileID: UUID) -> InsurancePolicy
	{
		InsurancePolicy(
			id: UUID(),
			profileID: profileID,
			residenceID: residenceID,
			type: .renters,
			provider: "",
			policyNumber: "",
			monthlyCost: nil,
			deductible: nil,
			coverageAmount: nil,
			startDate: nil,
			renewalDate: nil,
			isActive: true,
			backgroundColor: "red",
			url: "",
			notes: ""
		)
	}

	func delete(_ policy: InsurancePolicy) {
		withErrorReporting {
			try database.write { db in
				try InsurancePolicy.find(policy.id)
					.delete()
					.execute(db)
			}
		}
	}
}
