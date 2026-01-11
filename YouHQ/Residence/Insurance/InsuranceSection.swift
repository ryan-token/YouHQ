//
//  InsuranceSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/10/26.
//

import SwiftUI

struct InsuranceSection: View {
	@State private var vm: ViewModel
	let onTap: (() -> Void)?

	init(for policy: InsurancePolicy, onTap: (() -> Void)? = nil) {
		_vm = State(wrappedValue: ViewModel(policy: policy))
		self.onTap = onTap
	}

	var body: some View {
		if let policy = vm.policy {
			InfoSection(
				"\(vm.policyTitle) Insurance",
				backgroundColor: $vm.backgroundColor,
				onColorChange: { newColor in
					vm.updatePolicyBackgroundColor(newColor)
				},
				onTap: onTap
			) {
				if policy.provider.isNotEmpty {
					Text(policy.provider)
						.sectionTitle()
				}

				if policy.policyNumber.isNotEmpty {
					InfoRow("Policy number:", value: policy.policyNumber)
				}

				if let monthlyCost = policy.monthlyCost {
					InfoRow("Monthly cost:", value: "\(monthlyCost.asCost)")
				}

				if let deductible = policy.deductible {
					InfoRow("Deductible:", value: "\(deductible.asCost)")
				}

				if let coverageAmount = policy.coverageAmount {
					InfoRow(
						"Coverage amount:",
						value: "\(coverageAmount.asCost)"
					)
				}

				if let renewalDate = policy.renewalDate {
					InfoRow(
						"Renewal date:",
						value: renewalDate.formatted(
							date: .abbreviated,
							time: .omitted
						)
					)
				}

				if policy.url.isNotEmpty {
					LinkRow("Website:", url: policy.url)
				}

				if policy.notes.isNotEmpty {
					VStack(alignment: .leading, spacing: 4) {
						Text("Notes:")
							.font(.headline)
							.foregroundStyle(.white)
						Text(policy.notes)
							.foregroundStyle(.white)
					}
				}
			}
		} else {
			Color.clear
				.task { await vm.loadPolicyData() }
		}
	}
}

#Preview {
	InsuranceSection(for: InsurancePolicy.sampleData)
}
