//
//  LabeledField.swift
//  YouHQ
//
//  Created by Ryan Token on 1/11/26.
//

import SwiftUI

struct LabeledField<Content: View>: View {
	let label: String
	@ViewBuilder let content: () -> Content
	@FocusState private var isFocused: Bool

	var body: some View {
		LabeledContent {
			content()
				.focused($isFocused)
		} label: {
			HQText(label)
				.foregroundStyle(.secondary)
				.onTapGesture {
					isFocused = true
				}
		}
	}
}

#Preview {
	LabeledField(label: "Account Number") {
		TextField("", text: .constant("123456"))
	}
}
