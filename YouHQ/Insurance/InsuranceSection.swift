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
	let onColorChange: (Color) -> Void
	let onTap: (() -> Void)?
	@Environment(\.defaultCurrencyCode) private var defaultCurrencyCode

	private var resolvedCurrencyCode: String {
		policy.currencyCode ?? defaultCurrencyCode
	}

	var body: some View {
		InfoSection(
			"\(policy.type.rawValue) Insurance",
			backgroundColor: Color(databaseValue: policy.backgroundColor),
			onColorChange: onColorChange,
			onTap: onTap
		) {
			if policy.provider.isNotEmpty {
				HQText(policy.provider)
					.sectionTitle()
			}

			if policy.policyNumber.isNotEmpty {
				InfoRow("Policy number:", value: policy.policyNumber)
			}

			if let monthlyCost = policy.monthlyCost {
				InfoRow(
					"Monthly cost:",
					value: monthlyCost.formatted(currencyCode: resolvedCurrencyCode),
					blurred: hideCosts
				)
			}

			if let deductible = policy.deductible {
				InfoRow(
					"Deductible:",
					value: deductible.formatted(currencyCode: resolvedCurrencyCode),
					blurred: hideCosts
				)
			}

			if let coverageAmount = policy.coverageAmount {
				InfoRow(
					"Coverage amount:",
					value: coverageAmount.formatted(currencyCode: resolvedCurrencyCode),
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
					HQText("Notes:")
						.font(.headline)
						.foregroundStyle(.white)
					HQText(policy.notes)
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
		onColorChange: { _ in },
		onTap: nil
	)
}
