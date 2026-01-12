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

	var body: some View {
		LabeledContent {
			content()
		} label: {
			Text(label)
				.foregroundStyle(.secondary)
		}
	}
}

#Preview {
	LabeledField(label: "Account Number") {
		TextField("", text: .constant("123456"))
	}
}
