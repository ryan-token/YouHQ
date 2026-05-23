//
//  InfoSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/8/26.
//

import SwiftUI

struct InfoSection<Content: View>: View {
	let title: String
	let initialColor: Color
	let onColorChange: ((Color) -> Void)?
	let onTap: (() -> Void)?
	@ViewBuilder let content: Content
	@State private var backgroundColor: Color

	init(
		_ title: String,
		backgroundColor: Color,
		onColorChange: ((Color) -> Void)? = nil,
		onTap: (() -> Void)? = nil,
		@ViewBuilder content: () -> Content
	) {
		self.title = title
		self.initialColor = backgroundColor
		self._backgroundColor = State(initialValue: backgroundColor)
		self.onColorChange = onColorChange
		self.onTap = onTap
		self.content = content()
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack {
				HQText(title, italic: true)
					.font(.title3)
					.fontWeight(.semibold)
					.foregroundStyle(.secondary)

				Spacer()

				ColorPicker(
					"Background Color",
					selection: $backgroundColor,
					supportsOpacity: false
				)
				.labelsHidden()
				.onChange(of: backgroundColor) { _, newColor in
					onColorChange?(newColor)
				}
			}

			Group {
				if let onTap {
					Button(action: onTap) {
						contentStack
							.frame(minHeight: 24)
							.contentShape(.rect)
					}
					.buttonStyle(.plain)
				} else {
					contentStack
				}
			}
			.cardStyle(backgroundColor: backgroundColor)
		}
		.onChange(of: initialColor) { _, newColor in
			backgroundColor = newColor
		}
	}

	private var contentStack: some View {
		VStack(alignment: .leading, spacing: 4) {
			content
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}

#Preview("Info Section") {
	InfoSection("Info", backgroundColor: .indigo) {
		InfoRow("Full address:", value: "123 Main St, Springfield, IL 62701")
		InfoRow("Move-in date:", value: "Jan 1, 2024")
		InfoRow("Monthly cost:", value: "$1,500.00")
	}
	.padding()
}

#Preview("Custom Color") {
	InfoSection("Utility", backgroundColor: .blue) {
		InfoRow("Provider:", value: "Springfield Electric")
		InfoRow("Account number:", value: "12345678")
		InfoRow("Monthly cost:", value: "$150.00")
	}
	.padding()
}
