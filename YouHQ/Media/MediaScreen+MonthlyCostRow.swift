//
//  MediaScreen+MonthlyCostRow.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

extension MediaScreen {
	struct MonthlyCostRow: View {
		let totalCost: Double
		let serviceProviders: [ServiceProvider]
		let subscriptions: [Subscription]
		let blurred: Bool

		@State private var showPopover = false

		var body: some View {
			HStack(alignment: .center) {
				HQText("Monthly Media Cost:")
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
					MediaCostBreakdownView(
						serviceProviders: serviceProviders,
						subscriptions: subscriptions,
						totalCost: totalCost
					)
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding()
			.foregroundStyle(.white)
			.background(.teal.gradient)
			.clipShape(.rect(cornerRadius: 12))
		}
	}
}

#Preview {
	MediaScreen.MonthlyCostRow(
		totalCost: 280,
		serviceProviders: [ServiceProvider.sampleData],
		subscriptions: [Subscription.sampleData],
		blurred: false
	)
}
