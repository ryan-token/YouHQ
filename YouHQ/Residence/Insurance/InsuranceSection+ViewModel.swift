//
//  InsuranceSection+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/11/26.
//

import SQLiteData
import SwiftUI

extension InsuranceSection {
	@Observable
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		@ObservationIgnored
		@FetchOne(InsurancePolicy.none) var policy: InsurancePolicy?

		let policyID: UUID
		var policyTitle: String
		var backgroundColor: Color = .red
		var policyNotes: String {
			didSet {
				updatePolicyNotes()
			}
		}

		init(policy: InsurancePolicy) {
			self.policyID = policy.id
			self.policyTitle = policy.type.rawValue
			self.policyNotes = ""
		}

		func loadPolicyData() async {
			await loadPolicy()
			setInitialPolicyNotes()
			setInitialBackgroundColor()
		}

		// MARK: PRIVATE METHODS

		private func loadPolicy() async {
			_ = await withErrorReporting {
				try await $policy.load(
					InsurancePolicy.where { $0.id.eq(policyID) },
					animation: .default
				)
			}
		}

		private func setInitialPolicyNotes() {
			policyNotes = policy?.notes ?? ""
		}

		private func setInitialBackgroundColor() {
			backgroundColor = Color(
				databaseValue: policy?.backgroundColor ?? "red"
			)
		}

		private func updatePolicyNotes() {
			withErrorReporting {
				try database.write { db in
					try InsurancePolicy.find(policyID)
						.update { $0.notes = policyNotes }
						.execute(db)
				}
			}
		}

		func updatePolicyBackgroundColor(_ color: Color) {
			withErrorReporting {
				try database.write { db in
					try InsurancePolicy.find(policyID)
						.update { $0.backgroundColor = color.databaseValue }
						.execute(db)
				}
			}
		}
	}
}
