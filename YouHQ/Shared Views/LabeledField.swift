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
			HQText(label)
				.foregroundStyle(.secondary)
				.contentShape(.rect)
				.onTapGesture {
					isFocused = true
				}
		}
	}
}

#Preview {
	LabeledField("Account Number") {
		TextField("", text: .constant("123456"))
	}
}
