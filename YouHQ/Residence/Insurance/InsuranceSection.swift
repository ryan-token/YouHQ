//
//  InsuranceSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/10/26.
//

import SwiftUI

struct InsuranceSection: View {
	let policy: InsurancePolicy
	let hideCosts: Bool
	let onTap: (() -> Void)?

	var body: some View {
		InfoSection(
			"\(policy.type.rawValue) Insurance",
			backgroundColor: .constant(
				Color(databaseValue: policy.backgroundColor)
			),
			onColorChange: { _ in },
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
				InfoRow(
					"Monthly cost:",
					value: "\(monthlyCost.asCost)",
					blurred: hideCosts
				)
			}

			if let deductible = policy.deductible {
				InfoRow(
					"Deductible:",
					value: "\(deductible.asCost)",
					blurred: hideCosts
				)
			}

			if let coverageAmount = policy.coverageAmount {
				InfoRow(
					"Coverage amount:",
					value: "\(coverageAmount.asCost)",
					blurred: hideCosts
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
	}
}

#Preview {
	InsuranceSection(
		policy: InsurancePolicy.sampleData,
		hideCosts: false,
		onTap: nil
	)
}
