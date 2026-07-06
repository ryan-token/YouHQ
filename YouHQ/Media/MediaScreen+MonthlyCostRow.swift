//
//  MediaScreen+MonthlyCostRow.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

extension MediaScreen {
	struct MonthlyMediaCostRow: View {
		let totalCost: Double
		let serviceProviders: [ServiceProvider]
		let subscriptions: [Subscription]
		let blurred: Bool
		// The media total spans many records that may each carry their own
		// currency, so it falls back to the app-wide default rather than any
		// single record's currency.
		@Environment(\.defaultCurrencyCode) private var defaultCurrencyCode

		private var costLineItems: [CostLineItem] {
			var items: [CostLineItem] = []

			for provider in serviceProviders {
				if let cost = provider.monthlyCost {
					let label = provider.name.isEmpty ? provider.providerType.rawValue : provider.name
					items.append(CostLineItem(label: label, cost: cost))
				}
			}

			for subscription in subscriptions where subscription.isActive {
				if let cost = subscription.monthlyCost {
					let normalized = subscription.billingCycle == .annual ? cost / 12 : cost
					items.append(CostLineItem(label: subscription.name, cost: normalized))
				}
			}

			return items
		}

		var body: some View {
			MonthlyCostRow(
				"Monthly Media Cost:",
				totalCost: totalCost,
				currencyCode: defaultCurrencyCode,
				blurred: blurred
			) {
				CostBreakdownView(
					title: "Monthly Media Cost",
					lineItems: costLineItems,
					totalCost: totalCost,
					currencyCode: defaultCurrencyCode
				)
			}
			.legibleForeground(on: .teal)
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding()
			.background(.teal.gradient)
			.clipShape(.rect(cornerRadius: 12))
		}
	}
}

#Preview {
	MediaScreen.MonthlyMediaCostRow(
		totalCost: 280,
		serviceProviders: [ServiceProvider.sampleData],
		subscriptions: [Subscription.sampleData],
		blurred: false
	)
}
