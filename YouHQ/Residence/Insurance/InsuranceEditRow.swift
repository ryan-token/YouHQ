//
//  InsuranceEditRow.swift
//  YouHQ
//
//  Created by Ryan Token on 1/10/26.
//

import SQLiteData
import SwiftUI

struct InsuranceEditRow: View {
	@State private var vm: ViewModel

	init(policy: InsurancePolicy) {
		_vm = State(wrappedValue: ViewModel(policy: policy))
	}

	var body: some View {
		Section(vm.policy.type.rawValue) {
			TextField("Provider", text: $vm.provider)
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif
			TextField("Policy Number", text: $vm.policyNumber)

			TextField(
				"Monthly Cost",
				value: Binding(
					get: { vm.monthlyCost ?? 0 },
					set: { vm.monthlyCost = $0 }
				),
				format: .number
			)
			#if !os(macOS)
				.keyboardType(.decimalPad)
			#endif

			TextField(
				"Deductible",
				value: Binding(
					get: { vm.deductible ?? 0 },
					set: { vm.deductible = $0 }
				),
				format: .number
			)
			#if !os(macOS)
				.keyboardType(.decimalPad)
			#endif

			TextField(
				"Coverage Amount",
				value: Binding(
					get: { vm.coverageAmount ?? 0 },
					set: { vm.coverageAmount = $0 }
				),
				format: .number
			)
			#if !os(macOS)
				.keyboardType(.decimalPad)
			#endif

			DatePicker(
				"Renewal Date",
				selection: Binding(
					get: { vm.renewalDate ?? Date() },
					set: { vm.renewalDate = $0 }
				),
				displayedComponents: .date
			)

			URLTextField(text: $vm.url)

			TextField("Notes", text: $vm.notes, axis: .vertical)
				.lineLimit(3...6)
		}
	}
}

extension InsuranceEditRow {
	@Observable
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		let policy: InsurancePolicy

		var provider: String {
			didSet { saveChanges() }
		}
		var policyNumber: String {
			didSet { saveChanges() }
		}
		var monthlyCost: Double? {
			didSet { saveChanges() }
		}
		var deductible: Double? {
			didSet { saveChanges() }
		}
		var coverageAmount: Double? {
			didSet { saveChanges() }
		}
		var renewalDate: Date? {
			didSet { saveChanges() }
		}
		var url: String {
			didSet { saveChanges() }
		}
		var notes: String {
			didSet { saveChanges() }
		}

		init(policy: InsurancePolicy) {
			self.policy = policy
			provider = policy.provider
			policyNumber = policy.policyNumber
			monthlyCost = policy.monthlyCost
			deductible = policy.deductible
			coverageAmount = policy.coverageAmount
			renewalDate = policy.renewalDate
			url = policy.url
			notes = policy.notes
		}

		private func saveChanges() {
			withErrorReporting {
				try database.write { db in
					try InsurancePolicy.find(policy.id)
						.update {
							$0.provider = provider
							$0.policyNumber = policyNumber
							$0.monthlyCost = monthlyCost
							$0.deductible = deductible
							$0.coverageAmount = coverageAmount
							$0.renewalDate = renewalDate
							$0.url = url
							$0.notes = notes
						}
						.execute(db)
				}
			}
		}
	}
}

#Preview {
	Form {
		InsuranceEditRow(policy: InsurancePolicy.homeInsuranceSampleData)
	}
}
