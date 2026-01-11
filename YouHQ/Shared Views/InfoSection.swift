//
//  InfoSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/8/26.
//

import SwiftUI

struct InfoSection<Content: View>: View {
	let title: String
	@Binding var backgroundColor: Color
	let onColorChange: ((Color) -> Void)?
	@ViewBuilder let content: Content
	@State private var showColorPicker = false

	init(
		_ title: String,
		backgroundColor: Binding<Color>,
		onColorChange: ((Color) -> Void)? = nil,
		@ViewBuilder content: () -> Content
	) {
		self.title = title
		self._backgroundColor = backgroundColor
		self.onColorChange = onColorChange
		self.content = content()
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack {
				Text(title)
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
			.padding()
			.background {
				LinearGradient(
					colors: [
						backgroundColor,
						backgroundColor.opacity(0.8),
					],
					startPoint: .topLeading,
					endPoint: .bottomTrailing
				)
				.overlay {
					GrainTexture()
						.opacity(0.15)
						.blendMode(.overlay)
				}
			}
			.clipShape(.rect(cornerRadius: 16))
			.shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
			.padding(.bottom)
		}
	}
}

struct InfoRow: View {
	let label: String
	let value: String
	let isSelectable: Bool

	init(_ label: String, value: String, isSelectable: Bool = true) {
		self.label = label
		self.value = value
		self.isSelectable = isSelectable
	}

	var body: some View {
		HStack(alignment: .top) {
			Text(label)
				.font(.headline)
			Text(value)
				.if(isSelectable) {
					$0.textSelection(.enabled)
				}
		}
		.foregroundStyle(.white)
	}
}

#Preview("Info Section") {
	@Previewable @State var backgroundColor: Color = .indigo

	InfoSection("Info", backgroundColor: $backgroundColor) {
		InfoRow("Full address:", value: "123 Main St, Springfield, IL 62701")
		InfoRow("Move in date:", value: "Jan 1, 2024")
		InfoRow("Monthly cost:", value: "$1,500.00")
	}
	.padding()
}

#Preview("Custom Color") {
	@Previewable @State var backgroundColor: Color = .blue

	InfoSection("Utility", backgroundColor: $backgroundColor) {
		InfoRow("Provider:", value: "Springfield Electric")
		InfoRow("Account number:", value: "12345678")
		InfoRow("Monthly cost:", value: "$150.00")
	}
	.padding()
}
