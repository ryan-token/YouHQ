//
//  VehicleMonthlyCostRow.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct VehicleMonthlyCostRow: View {
	let label: String
	let totalCost: Double
	let vehicleCost: Double?
	let vehicleCostType: VehicleCostType
	let insurancePolicies: [InsurancePolicy]
	let others: [Other]
	let blurred: Bool

	@State private var showPopover = false

	init(
		_ label: String,
		totalCost: Double,
		vehicleCost: Double?,
		vehicleCostType: VehicleCostType,
		insurancePolicies: [InsurancePolicy],
		others: [Other],
		blurred: Bool = false
	) {
		self.label = label
		self.totalCost = totalCost
		self.vehicleCost = vehicleCost
		self.vehicleCostType = vehicleCostType
		self.insurancePolicies = insurancePolicies
		self.others = others
		self.blurred = blurred
	}

	var body: some View {
		HStack(alignment: .center) {
			HQText(label)
				.font(.headline)
			Button {
				showPopover.toggle()
			} label: {
				HQText(totalCost.asCost)
					.lineLimit(1)
					.blur(radius: blurred ? 4 : 0)
					.padding(.horizontal, 12)
					.padding(.vertical, 4)
					.background(.white.opacity(0.3))
					.clipShape(.rect(cornerRadius: 8))
			}
			.buttonStyle(.plain)
			.popover(isPresented: $showPopover) {
				VehicleCostBreakdownView(
					vehicleCost: vehicleCost,
					vehicleCostType: vehicleCostType,
					insurancePolicies: insurancePolicies,
					others: others,
					totalCost: totalCost
				)
			}
		}
		.foregroundStyle(.white)
	}
}

#Preview {
	VehicleMonthlyCostRow(
		"Monthly TCO:",
		totalCost: 350,
		vehicleCost: 35_000,
		vehicleCostType: .owned,
		insurancePolicies: [InsurancePolicy.sampleData],
		others: [Other.sampleData]
	)
}
