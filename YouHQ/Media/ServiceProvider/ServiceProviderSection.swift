//
//  ServiceProviderSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct ServiceProviderSection: View {
	let serviceProvider: ServiceProvider
	let hideCosts: Bool
	let onColorChange: (Color) -> Void
	let onTap: (() -> Void)?

	var body: some View {
		InfoSection(
			serviceProvider.providerType.rawValue,
			backgroundColor: Color(databaseValue: serviceProvider.backgroundColor),
			onColorChange: onColorChange,
			onTap: onTap
		) {
			if serviceProvider.name.isNotEmpty {
				HQText(serviceProvider.name)
					.sectionTitle()
			}

			if serviceProvider.accountNumber.isNotEmpty {
				InfoRow("Account number:", value: serviceProvider.accountNumber)
			}

			if let monthlyCost = serviceProvider.monthlyCost {
				InfoRow(
					"Monthly cost:",
					value: "\(monthlyCost.asCost)",
					blurred: hideCosts
				)
			}

			if serviceProvider.url.isNotEmpty {
				LinkRow("Website:", url: serviceProvider.url)
			}

			if serviceProvider.notes.isNotEmpty {
				VStack(alignment: .leading, spacing: 4) {
					HQText("Notes:")
						.font(.headline)
						.foregroundStyle(.white)
					HQText(serviceProvider.notes)
						.foregroundStyle(.white)
				}
			}
		}
	}
}

#Preview {
	ServiceProviderSection(
		serviceProvider: ServiceProvider(
			id: UUID(),
			profileID: UUID(),
			providerType: .internet,
			name: "Comcast",
			monthlyCost: 89.99,
			accountNumber: "12345678",
			backgroundColor: "purple",
			url: "https://xfinity.com",
			notes: "Fiber connection"
		),
		hideCosts: false,
		onColorChange: { _ in },
		onTap: nil
	)
}
