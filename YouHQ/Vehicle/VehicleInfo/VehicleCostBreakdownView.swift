//
//  VehicleCostBreakdownView.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct VehicleCostBreakdownView: View {
	@Environment(\.colorScheme) var colorScheme

	let vehicleCost: Double?
	let vehicleCostType: VehicleCostType
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
					// Vehicle cost (payment) - but not if owned
					if let vehicleCost, vehicleCostType != .owned {
						HStack {
							Text(vehicleCostType.rawValue)
							Spacer()
							Text(vehicleCost.asCost)
								.fontWeight(.medium)
						}
						.font(.body)
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
		.foregroundStyle(colorScheme == .light ? .black : .white)
	}
}

#Preview {
	VehicleCostBreakdownView(
		vehicleCost: 130,
		vehicleCostType: .loanPayment,
		insurancePolicies: [InsurancePolicy.sampleData],
		others: [Other.sampleData],
		totalCost: 350
	)
}
