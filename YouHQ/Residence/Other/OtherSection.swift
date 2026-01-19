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
	let onTap: (() -> Void)?

	var body: some View {
		InfoSection(
			other.name.isNotEmpty ? other.name : "Other",
			backgroundColor: .constant(
				Color(databaseValue: other.backgroundColor)
			),
			onColorChange: { _ in },
			onTap: onTap
		) {
			if other.name.isNotEmpty {
				Text(other.name)
					.sectionTitle()
			}

			if other.otherDescription.isNotEmpty {
				InfoRow("Description:", value: other.otherDescription)
			}

			if let monthlyCost = other.monthlyCost {
				InfoRow(
					"Monthly cost:",
					value: monthlyCost.asCost,
					blurred: hideCosts
				)
			}

			if other.url.isNotEmpty {
				LinkRow("Website:", url: other.url)
			}

			if other.notes.isNotEmpty {
				VStack(alignment: .leading, spacing: 4) {
					Text("Notes:")
						.font(.headline)
						.foregroundStyle(.white)
					Text(other.notes)
						.foregroundStyle(.white)
				}
			}
		}
	}
}

#Preview {
	OtherSection(other: Other.sampleData, hideCosts: false, onTap: nil)
}
