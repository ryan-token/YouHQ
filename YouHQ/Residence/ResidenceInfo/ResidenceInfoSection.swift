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

	// Computed property for total monthly cost
	var totalMonthlyCost: Double {
		var total: Double = 0

		// Add residence monthly cost (rent/mortgage) - but not if owned
		if let residenceCost = residence.monthlyCost,
			residence.costType != .owned
		{
			total += residenceCost
		}

		// Add utility costs
		for utility in utilities {
			if let utilityCost = utility.approximateMonthlyCost {
				total += utilityCost
			}
		}

		// Add insurance policy costs
		for policy in insurancePolicies {
			if let policyCost = policy.monthlyCost {
				total += policyCost
			}
		}

		// Add other costs
		for other in others {
			if let otherCost = other.monthlyCost {
				total += otherCost
			}
		}

		return total
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
			Text(residence.address)
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
					value: "\(monthlyCost.asCost)",
					blurred: hideCosts
				)
			}

			if totalMonthlyCost > 0 {
				MonthlyTCORow(
					"Monthly TCO:",
					totalCost: totalMonthlyCost,
					residenceCost: residence.monthlyCost,
					residenceCostType: residence.costType,
					utilities: utilities,
					insurancePolicies: insurancePolicies,
					others: others,
					blurred: hideCosts
				)
			}

			if residence.url.isNotEmpty {
				LinkRow("Website:", url: residence.url)
			}

			if residence.notes.isNotEmpty {
				VStack(alignment: .leading, spacing: 4) {
					Text("Notes:")
						.font(.headline)
						.foregroundStyle(.white)
					Text(residence.notes)
						.foregroundStyle(.white)
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
