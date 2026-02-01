//
//  SubscriptionSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct SubscriptionSection: View {
	let subscription: Subscription
	let hideCosts: Bool
	let onColorChange: (Color) -> Void
	let onTap: (() -> Void)?

	var body: some View {
		InfoSection(
			subscription.category.rawValue,
			backgroundColor: Color(databaseValue: subscription.backgroundColor),
			onColorChange: onColorChange,
			onTap: onTap
		) {
			if subscription.name.isNotEmpty {
				HQText(subscription.name)
					.sectionTitle()
			}

			if let monthlyCost = subscription.monthlyCost {
				InfoRow(
					subscription.billingCycle == .annual ? "Annual cost:" : "Monthly cost:",
					value: "\(monthlyCost.asCost)",
					blurred: hideCosts
				)
			}

			InfoRow("Billing cycle:", value: subscription.billingCycle.rawValue)

			if let renewalDate = subscription.renewalDate {
				InfoRow(
					"Renewal date:",
					value: renewalDate.formatted(
						date: .abbreviated,
						time: .omitted
					)
				)
			}

			InfoRow("Status:", value: subscription.isActive ? "Active" : "Inactive")

			if subscription.url.isNotEmpty {
				LinkRow("Website:", url: subscription.url)
			}

			if subscription.notes.isNotEmpty {
				VStack(alignment: .leading, spacing: 4) {
					HQText("Notes:")
						.font(.headline)
						.foregroundStyle(.white)
					HQText(subscription.notes)
						.foregroundStyle(.white)
				}
			}
		}
	}
}

#Preview {
	SubscriptionSection(
		subscription: Subscription(
			id: UUID(),
			profileID: UUID(),
			name: "Netflix",
			category: .streaming,
			monthlyCost: 15.99,
			billingCycle: .monthly,
			renewalDate: Date(),
			isActive: true,
			backgroundColor: "orange",
			url: "https://netflix.com",
			notes: "Premium plan"
		),
		hideCosts: false,
		onColorChange: { _ in },
		onTap: nil
	)
}
