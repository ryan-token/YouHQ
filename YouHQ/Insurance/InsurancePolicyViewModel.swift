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

	func loadVehicle(for vehicleID: UUID) async {
		_ = await withErrorReporting {
			try await $insurancePolicies.load(
				InsurancePolicy
					.where { $0.vehicleID.eq(vehicleID) }
					.order { $0.type },
				animation: .default
			)
		}
	}

	func createDraft(for residenceID: UUID, profileID: UUID) -> InsurancePolicy {
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

	func createVehicleDraft(for vehicleID: UUID, profileID: UUID) -> InsurancePolicy {
		InsurancePolicy(
			id: UUID(),
			profileID: profileID,
			residenceID: nil,
			vehicleID: vehicleID,
			type: .auto,
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
		do {
			try database.write { db in
				try InsurancePolicy.find(policy.id)
					.delete()
					.execute(db)
			}
		} catch {
			Analytics.logError(id: .insurancePolicyDeleteFailed, message: error.localizedDescription)
			reportIssue(error)
		}
	}

	func updateBackgroundColor(_ color: Color, for policy: InsurancePolicy) {
		withErrorReporting {
			try database.write { db in
				try InsurancePolicy.find(policy.id)
					.update { $0.backgroundColor = color.databaseValue }
					.execute(db)
			}

			Analytics.sendSignal(.itemBackgroundColorChanged)
		}
	}
}
