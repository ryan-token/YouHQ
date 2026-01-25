//
//  MediaCostBreakdownView.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct MediaCostBreakdownView: View {
	@Environment(\.colorScheme) var colorScheme

	let serviceProviders: [ServiceProvider]
	let subscriptions: [Subscription]
	let totalCost: Double

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 12) {
				Text("Monthly Media Cost")
					.font(.title2)
					.fontWeight(.semibold)
					.padding(.bottom, 4)

				VStack(alignment: .leading, spacing: 8) {
					// Service Providers
					if let firstProvider = serviceProviders.first, let cost = firstProvider.monthlyCost {
						HStack {
							Text("\(firstProvider.name.isEmpty ? firstProvider.providerType.rawValue : firstProvider.name)")
							Spacer()
							Text(cost.asCost)
								.fontWeight(.medium)
						}
					}

					ForEach(serviceProviders.dropFirst()) { serviceProvider in
						if let cost = serviceProvider.monthlyCost {
							HStack {
								Text("+ \(serviceProvider.name.isEmpty ? serviceProvider.providerType.rawValue : serviceProvider.name)")
								Spacer()
								Text(cost.asCost)
									.fontWeight(.medium)
							}
						}
					}

					// Subscriptions (only active)
					ForEach(subscriptions.filter { $0.isActive }) { subscription in
						if let cost = subscription.monthlyCost {
							HStack {
								Text("+ \(subscription.name)")
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
	MediaCostBreakdownView(
		serviceProviders: [ServiceProvider.sampleData],
		subscriptions: [Subscription.sampleData],
		totalCost: 230
	)
}
