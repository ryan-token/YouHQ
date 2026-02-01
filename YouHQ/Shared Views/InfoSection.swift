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
				HQText(title)
					.font(.title3)
					.fontWeight(.semibold)
					.italic()
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

			VStack(alignment: .leading, spacing: 4) {
				content
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.if(onTap != nil) { view in
				Button(action: onTap!) {
					view
						.frame(minHeight: 24)
						.contentShape(.rect)
				}
				.buttonStyle(.plain)
			}
			.cardStyle(backgroundColor: backgroundColor)
		}
		.onChange(of: initialColor) { _, newColor in
			backgroundColor = newColor
		}
	}
}

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
			HQText(value)
				.if(isSelectable) {
					$0.textSelection(.enabled)
				}
				.blur(radius: blurred ? 4 : 0)
		}
		.foregroundStyle(.white)
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
