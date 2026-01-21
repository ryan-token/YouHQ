//
//  MonthlyTCORow.swift
//  YouHQ
//
//  Created by Ryan Token on 1/12/26.
//

import SwiftUI

struct MonthlyTCORow: View {
	let label: String
	let totalCost: Double
	let residenceCost: Double?
	let residenceCostType: CostType
	let utilities: [Utility]
	let insurancePolicies: [InsurancePolicy]
	let others: [Other]
	let blurred: Bool

	@State private var showPopover = false

	init(
		_ label: String,
		totalCost: Double,
		residenceCost: Double?,
		residenceCostType: CostType,
		utilities: [Utility],
		insurancePolicies: [InsurancePolicy],
		others: [Other],
		blurred: Bool = false
	) {
		self.label = label
		self.totalCost = totalCost
		self.residenceCost = residenceCost
		self.residenceCostType = residenceCostType
		self.utilities = utilities
		self.insurancePolicies = insurancePolicies
		self.others = others
		self.blurred = blurred
	}

	var body: some View {
		HStack(alignment: .center) {
			Group {
				Text(label)
					.font(.headline)
				Button {
					showPopover.toggle()
				} label: {
					Text(totalCost.asCost)
						.lineLimit(1)
						.blur(radius: blurred ? 4 : 0)
						.padding(.horizontal, 12)
						.padding(.vertical, 4)
						.background(.white.opacity(0.3))
						.clipShape(.rect(cornerRadius: 8))
				}
				.buttonStyle(.plain)
			}
			.foregroundStyle(.white)
		}
		.popover(isPresented: $showPopover) {
			CostBreakdownView(
				residenceCost: residenceCost,
				residenceCostType: residenceCostType,
				utilities: utilities,
				insurancePolicies: insurancePolicies,
				others: others,
				totalCost: totalCost
			)
		}
	}
}

struct CostBreakdownView: View {
	let residenceCost: Double?
	let residenceCostType: CostType
	let utilities: [Utility]
	let insurancePolicies: [InsurancePolicy]
	let others: [Other]
	let totalCost: Double

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 12) {
				Text("Monthly Total Cost of Ownership")
					.font(.title2)
					.fontWeight(.semibold)
					.padding(.bottom, 4)

				VStack(alignment: .leading, spacing: 8) {
					// Residence cost (rent/mortgage) - but not if owned
					if let residenceCost, residenceCostType != .owned {
						HStack {
							Text(residenceCostType.rawValue)
							Spacer()
							Text(residenceCost.asCost)
								.fontWeight(.medium)
						}
						.font(.body)
					}

					// Utilities
					ForEach(utilities) { utility in
						if let cost = utility.approximateMonthlyCost {
							HStack {
								Text("+ \(utility.type.rawValue)")
								Spacer()
								Text(cost.asCost)
									.fontWeight(.medium)
							}
							.font(.body)
						}
					}

					// Insurance policies
					ForEach(insurancePolicies) { policy in
						if let cost = policy.monthlyCost {
							HStack {
								Text("+ \(policy.type.rawValue) Insurance")
								Spacer()
								Text(cost.asCost)
									.fontWeight(.medium)
							}
							.font(.body)
						}
					}

					// Others
					ForEach(others) { other in
						if let cost = other.monthlyCost {
							HStack {
								Text("+ \(other.name)")
								Spacer()
								Text(cost.asCost)
									.fontWeight(.medium)
							}
							.font(.body)
						}
					}

					Divider()
						.padding(.vertical, 4)

					// Total
					HStack {
						Text("Total")
							.fontWeight(.semibold)
						Spacer()
						Text(totalCost.asCost)
							.fontWeight(.bold)
					}
					.font(.title3)
				}
			}
			.padding()
			.frame(minWidth: 300)
		}
	}
}

#Preview {
	VStack(spacing: 20) {
		MonthlyTCORow(
			"Monthly TCO:",
			totalCost: 2500.00,
			residenceCost: 2000.00,
			residenceCostType: .rent,
			utilities: [
				Utility(
					id: UUID(),
					residenceID: UUID(),
					type: .electric,
					provider: "Electric Co",
					accountNumber: "123",
					approximateMonthlyCost: 150.00,
					backgroundColor: "blue",
					url: "",
					notes: ""
				),
				Utility(
					id: UUID(),
					residenceID: UUID(),
					type: .internet,
					provider: "ISP",
					accountNumber: "456",
					approximateMonthlyCost: 100.00,
					backgroundColor: "blue",
					url: "",
					notes: ""
				)
			],
			insurancePolicies: [
				InsurancePolicy(
					id: UUID(),
					profileID: UUID(),
					residenceID: UUID(),
					type: .renters,
					provider: "Insurance Co",
					policyNumber: "789",
					monthlyCost: 250.00,
					deductible: nil,
					coverageAmount: nil,
					startDate: nil,
					renewalDate: nil,
					isActive: true,
					backgroundColor: "red",
					url: "",
					notes: ""
				)
			],
			others: []
		)
		.padding()
		.background(.indigo)
		.clipShape(.rect(cornerRadius: 16))
	}
	.padding()
}
