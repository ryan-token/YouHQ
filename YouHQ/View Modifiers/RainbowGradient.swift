//
//  RainbowGradient.swift
//  YouHQ
//
//  Created by Ryan Token on 2/22/26.
//

import SwiftUI

struct RainbowGradient: ViewModifier {
	func body(content: Content) -> some View {
		content
			.foregroundStyle(
				LinearGradient(
					colors: [.pink, .orange, .yellow, .green, .blue, .purple], startPoint: .leading, endPoint: .trailing
				)
			)
	}
}

extension View {
	func rainbowGradient() -> some View {
		modifier(RainbowGradient())
	}
}
