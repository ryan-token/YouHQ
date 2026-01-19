//
//  UtilitySection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/2/26.
//

import SwiftUI

struct UtilitySection: View {
	let utility: Utility
	let hideCosts: Bool
	let onTap: (() -> Void)?

	var body: some View {
		InfoSection(
			utility.type.rawValue,
			backgroundColor: .constant(
				Color(databaseValue: utility.backgroundColor)
			),
			onColorChange: { _ in },
			onTap: onTap
		) {
			if utility.provider.isNotEmpty {
				Text(utility.provider)
					.sectionTitle()
			}

			if utility.accountNumber.isNotEmpty {
				InfoRow("Account number:", value: utility.accountNumber)
			}

			if let appxMonthlyCost = utility.approximateMonthlyCost {
				InfoRow(
					"Monthly cost:",
					value: "\(appxMonthlyCost.asCost)",
					blurred: hideCosts
				)
			}

			if utility.url.isNotEmpty {
				LinkRow("Website:", url: utility.url)
			}

			if utility.notes.isNotEmpty {
				VStack(alignment: .leading, spacing: 4) {
					Text("Notes:")
						.font(.headline)
						.foregroundStyle(.white)
					Text(utility.notes)
						.foregroundStyle(.white)
				}
			}
		}
	}
}

#Preview {
	UtilitySection(utility: Utility.sampleData, hideCosts: false, onTap: nil)
}
