//
//  ResidenceInfoSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/11/26.
//

import SQLiteData
import SwiftUI

struct ResidenceInfoSection: View {
	let residence: Residence
	let utilities: [Utility]
	let insurancePolicies: [InsurancePolicy]
	let others: [Other]
	let hideCosts: Bool
	let backgroundColor: Color
	let onTap: ((Residence) -> Void)?
	let onColorChange: (Color) -> Void
	@Environment(\.defaultCurrencyCode) private var defaultCurrencyCode

	private var resolvedCurrencyCode: String {
		residence.currencyCode ?? defaultCurrencyCode
	}

	init(
		residence: Residence,
		utilities: [Utility],
		insurancePolicies: [InsurancePolicy],
		others: [Other],
		hideCosts: Bool = false,
		backgroundColor: Color,
		onTap: ((Residence) -> Void)? = nil,
		onColorChange: @escaping (Color) -> Void
	) {
		self.residence = residence
		self.utilities = utilities
		self.insurancePolicies = insurancePolicies
		self.others = others
		self.hideCosts = hideCosts
		self.backgroundColor = backgroundColor
		self.onTap = onTap
		self.onColorChange = onColorChange
	}

	private var costLineItems: [CostLineItem] {
		var items: [CostLineItem] = []

		if let residenceCost = residence.monthlyCost, residence.costType != .owned {
			items.append(CostLineItem(label: residence.costType.rawValue, cost: residenceCost))
		}

		for utility in utilities {
			if let cost = utility.approximateMonthlyCost {
				items.append(CostLineItem(label: utility.type.rawValue, cost: cost))
			}
		}

		for policy in insurancePolicies {
			if let cost = policy.monthlyCost {
				items.append(CostLineItem(label: "\(policy.type.rawValue) Insurance", cost: cost))
			}
		}

		for other in others {
			if let cost = other.monthlyCost {
				items.append(CostLineItem(label: other.name, cost: cost))
			}
		}

		return items
	}

	private var totalMonthlyCost: Double {
		costLineItems.reduce(0) { $0 + $1.cost }
	}

	var body: some View {
		InfoSection(
			"Info",
			backgroundColor: backgroundColor,
			onColorChange: onColorChange,
			onTap: {
				onTap?(residence)
			}
		) {
			HQText(residence.address)
				.sectionTitle()

			if let moveInDate = residence.moveInDate {
				InfoRow(
					"Move-in date:",
					value: moveInDate.formatted(
						date: .abbreviated,
						time: .omitted
					)
				)
			}

			if let moveOutDate = residence.moveOutDate {
				InfoRow(
					"Move-out date:",
					value: moveOutDate.formatted(
						date: .abbreviated,
						time: .omitted
					)
				)
			}

			if let monthlyCost = residence.monthlyCost,
				residence.costType != .owned
			{
				InfoRow(
					"Monthly \(residence.costType.rawValue.lowercased()):",
					value: monthlyCost.formatted(currencyCode: resolvedCurrencyCode),
					blurred: hideCosts
				)
			}

			if totalMonthlyCost > 0 {
				MonthlyCostRow("Monthly TCO:", totalCost: totalMonthlyCost, blurred: hideCosts) {
					CostBreakdownView(
						title: "Monthly Total Cost of Ownership",
						lineItems: costLineItems,
						totalCost: totalMonthlyCost
					)
				}
			}

			if residence.url.isNotEmpty {
				LinkRow("Website:", url: residence.url)
			}

			if residence.notes.isNotEmpty {
				VStack(alignment: .leading, spacing: 4) {
					HQText("Notes:")
						.font(.headline)
					HQText(residence.notes)
				}
			}
		}
	}
}

#Preview {
	ResidenceInfoSection(
		residence: Residence.sampleData,
		utilities: [],
		insurancePolicies: [],
		others: [],
		hideCosts: false,
		backgroundColor: .indigo,
		onTap: nil,
		onColorChange: { _ in }
	)
}
