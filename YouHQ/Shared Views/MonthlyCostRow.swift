//
//  MonthlyCostRow.swift
//  YouHQ
//
//  Created by Ryan Token on 1/12/26.
//

import SwiftUI

/// A row that shows a label + total cost button, with a popover breakdown.
///
/// Used by residence, vehicle, and media tabs to display their respective
/// monthly cost totals. The breakdown content is built by the caller so each
/// domain can supply its own title and line items.
struct MonthlyCostRow: View {
	let label: String
	let totalCost: Double
	let currencyCode: String
	let blurred: Bool
	@ViewBuilder let breakdown: CostBreakdownView

	@Environment(\.cardForegroundColor) private var cardForegroundColor
	@State private var showPopover = false

	init(
		_ label: String,
		totalCost: Double,
		currencyCode: String,
		blurred: Bool = false,
		@ViewBuilder breakdown: () -> CostBreakdownView
	) {
		self.label = label
		self.totalCost = totalCost
		self.currencyCode = currencyCode
		self.blurred = blurred
		self.breakdown = breakdown()
	}

	var body: some View {
		HStack(alignment: .center) {
			HQText(label)
				.font(.headline)
			Button {
				showPopover.toggle()
			} label: {
				HQText(totalCost.formatted(currencyCode: currencyCode))
					.lineLimit(1)
					.blur(radius: blurred ? 4 : 0)
					.padding(.horizontal, 12)
					.padding(.vertical, 4)
					.background(cardForegroundColor.opacity(0.2))
					.clipShape(.rect(cornerRadius: 8))
			}
			.buttonStyle(.plain)
			.popover(isPresented: $showPopover) {
				breakdown
			}
		}
	}
}

#Preview {
	MonthlyCostRow("Monthly TCO:", totalCost: 2500, currencyCode: "USD") {
		CostBreakdownView(
			title: "Monthly Total Cost of Ownership",
			lineItems: [
				CostLineItem(label: "Mortgage", cost: 2000),
				CostLineItem(label: "Electric", cost: 150),
				CostLineItem(label: "Internet", cost: 100),
				CostLineItem(label: "Renters Insurance", cost: 250)
			],
			totalCost: 2500,
			currencyCode: "USD"
		)
	}
	.padding()
	.background(.indigo)
	.clipShape(.rect(cornerRadius: 16))
	.padding()
}
