//
//  InfoRow.swift
//  YouHQ
//
//  Created by Ryan Token on 1/8/26.
//

import SwiftUI

struct InfoRow: View {
	let label: String
	let value: String
	let isSelectable: Bool
	let blurred: Bool

	init(
		_ label: String,
		value: String,
		isSelectable: Bool = true,
		blurred: Bool = false
	) {
		self.label = label
		self.value = value
		self.isSelectable = isSelectable
		self.blurred = blurred
	}

	var body: some View {
		HStack(alignment: .top) {
			HQText(label)
				.font(.headline)
			Group {
				if isSelectable {
					HQText(value).textSelection(.enabled)
				} else {
					HQText(value)
				}
			}
			.blur(radius: blurred ? 4 : 0)
		}
	}
}

#Preview {
	VStack(alignment: .leading) {
		InfoRow("Full address:", value: "123 Main St, Springfield, IL 62701")
		InfoRow("Move-in date:", value: "Jan 1, 2024")
		InfoRow("Monthly cost:", value: "$1,500.00")
	}
	.padding()
	.background(.indigo)
}
