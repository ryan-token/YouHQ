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
	let onColorChange: (Color) -> Void
	let onTap: (() -> Void)?
	@Environment(\.defaultCurrencyCode) private var defaultCurrencyCode

	private var resolvedCurrencyCode: String {
		utility.currencyCode ?? defaultCurrencyCode
	}

	var body: some View {
		InfoSection(
			utility.type.rawValue,
			backgroundColor: Color(databaseValue: utility.backgroundColor),
			onColorChange: onColorChange,
			onTap: onTap
		) {
			if utility.provider.isNotEmpty {
				HQText(utility.provider)
					.sectionTitle()
			}

			if utility.accountNumber.isNotEmpty {
				InfoRow("Account number:", value: utility.accountNumber)
			}

			if let appxMonthlyCost = utility.approximateMonthlyCost {
				InfoRow(
					"Monthly cost:",
					value: appxMonthlyCost.formatted(currencyCode: resolvedCurrencyCode),
					blurred: hideCosts
				)
			}

			if utility.url.isNotEmpty {
				LinkRow("Website:", url: utility.url)
			}

			if utility.notes.isNotEmpty {
				VStack(alignment: .leading, spacing: 4) {
					HQText("Notes:")
						.font(.headline)
						.foregroundStyle(.white)
					HQText(utility.notes)
						.foregroundStyle(.white)
				}
			}
		}
	}
}

#Preview {
	UtilitySection(
		utility: Utility.sampleData,
		hideCosts: false,
		onColorChange: { _ in },
		onTap: nil
	)
}
