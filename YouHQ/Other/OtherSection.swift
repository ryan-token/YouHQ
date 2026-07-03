//
//  OtherSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/11/26.
//

import SwiftUI

struct OtherSection: View {
	let other: Other
	let hideCosts: Bool
	let onColorChange: (Color) -> Void
	let onTap: (() -> Void)?
	@Environment(\.defaultCurrencyCode) private var defaultCurrencyCode

	private var resolvedCurrencyCode: String {
		other.currencyCode ?? defaultCurrencyCode
	}

	var body: some View {
		InfoSection(
			other.name.isNotEmpty ? other.name : "Other",
			backgroundColor: Color(databaseValue: other.backgroundColor),
			onColorChange: onColorChange,
			onTap: onTap
		) {
			if other.name.isNotEmpty {
				HQText(other.name)
					.sectionTitle()
			}

			if other.otherDescription.isNotEmpty {
				InfoRow("Description:", value: other.otherDescription)
			}

			if let monthlyCost = other.monthlyCost {
				InfoRow(
					"Monthly cost:",
					value: monthlyCost.formatted(currencyCode: resolvedCurrencyCode),
					blurred: hideCosts
				)
			}

			if other.url.isNotEmpty {
				LinkRow("Website:", url: other.url)
			}

			if other.notes.isNotEmpty {
				VStack(alignment: .leading, spacing: 4) {
					HQText("Notes:")
						.font(.headline)
						.foregroundStyle(.white)
					HQText(other.notes)
						.foregroundStyle(.white)
				}
			}
		}
	}
}

#Preview {
	OtherSection(
		other: Other.sampleData,
		hideCosts: false,
		onColorChange: { _ in },
		onTap: nil
	)
}
