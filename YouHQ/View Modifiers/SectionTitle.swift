//
//  SectionTitle.swift
//  YouHQ
//
//  Created by Ryan Token on 1/10/26.
//

import SwiftUI

struct SectionTitle: ViewModifier {
	func body(content: Content) -> some View {
		content
			.font(.title2)
			.foregroundStyle(.white)
			.opacity(0.8)
			.padding(.bottom, 8)
			.textSelection(.enabled)
	}
}

extension View {
	func sectionTitle() -> some View {
		modifier(SectionTitle())
	}
}

#Preview {
    Text("Xcel")
		.sectionTitle()
}
