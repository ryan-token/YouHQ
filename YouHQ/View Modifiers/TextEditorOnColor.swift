//
//  TextEditorOnColor.swift
//  YouHQ
//
//  Created by Ryan Token on 1/10/26.
//

import SwiftUI

struct TextEditorOnColor: ViewModifier {
	let minHeight: CGFloat?

	init(minHeight: CGFloat? = 40) {
		self.minHeight = minHeight
	}

	func body(content: Content) -> some View {
		content
			.frame(minHeight: minHeight)
			.padding(.leading, 4)
			.foregroundStyle(.white)
			.textSelection(.enabled)
			.scrollContentBackground(.hidden)
			.tint(.white)
	}
}

extension View {
	func textEditorOnColor(minHeight: CGFloat? = 40) -> some View {
		modifier(TextEditorOnColor(minHeight: minHeight))
	}
}

#Preview {
	HQText("Xcel")
		.sectionTitle()
}
