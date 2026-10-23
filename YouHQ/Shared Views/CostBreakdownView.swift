//
//  CostBreakdownView.swift
//  YouHQ
//
//  Created by Ryan Token on 1/12/26.
//

import SwiftUI

/// A popover-style breakdown showing labeled line items and a total.
///
/// Used by `MonthlyCostRow` to power the residence, vehicle, and media cost
/// breakdowns. The first line item renders without a leading `+`; subsequent
/// items get a `+` prefix.
struct CostBreakdownView: View {
	let title: String
	let lineItems: [CostLineItem]
	let totalCost: Double
	let currencyCode: String

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 12) {
				HQText(title)
					.font(.title2)
					.fontWeight(.semibold)
					.padding(.bottom, 4)

				VStack(alignment: .leading, spacing: 8) {
					ForEach(lineItems.enumerated(), id: \.element.id) { index, item in
						HStack {
							HQText(index == 0 ? item.label : "+ \(item.label)")
							Spacer()
							HQText(item.cost.formatted(currencyCode: currencyCode))
								.fontWeight(.medium)
						}
						.font(.body)
					}

					Divider()
						.padding(.vertical, 4)

					HStack {
						HQText("Total")
							.fontWeight(.semibold)
						Spacer()
						HQText(totalCost.formatted(currencyCode: currencyCode))
							.bold()
					}
					.font(.title3)
				}
			}
			.padding()
			.frame(minWidth: 300)
		}
		// Reset to the plain label color: the popover otherwise inherits the card's legible
		// foreground, which may be white on a light popover background.
		.foregroundStyle(Color.primary)
	}
}

#Preview {
	CostBreakdownView(
		title: "Monthly Total Cost of Ownership",
		lineItems: [
			CostLineItem(id: UUID(), label: "Mortgage", cost: 2000),
			CostLineItem(id: UUID(), label: "Electric", cost: 150),
			CostLineItem(id: UUID(), label: "Internet", cost: 100),
			CostLineItem(id: UUID(), label: "Renters Insurance", cost: 250)
		],
		totalCost: 2500,
		currencyCode: "USD"
	)
}
