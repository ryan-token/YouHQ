//
//  LabeledField.swift
//  YouHQ
//
//  Created by Ryan Token on 1/11/26.
//

import SwiftUI

struct LabeledField<Content: View>: View {
	@FocusState private var isFocused: Bool

	let label: String
	@ViewBuilder let content: Content

	init(
		_ label: String,
		@ViewBuilder content: () -> Content
	) {
		self.label = label
		self.content = content()
	}

	var body: some View {
		LabeledContent {
			content
				.focused($isFocused)
		} label: {
			// Tapping the label focuses its field, like tapping a label in Settings.
			Button(action: focusField) {
				HQText(label)
					.foregroundStyle(.secondary)
					.contentShape(.rect)
			}
			.buttonStyle(.plain)
		}
	}

	private func focusField() {
		isFocused = true
	}
}

#Preview {
	LabeledField("Account Number") {
		TextField("", text: .constant("123456"))
	}
}
