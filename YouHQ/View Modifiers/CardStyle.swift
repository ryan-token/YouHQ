//
//  CardStyle.swift
//  YouHQ
//
//  Created by Ryan Token on 1/11/26.
//

import SwiftUI

struct CardStyle: ViewModifier {
	let backgroundColor: Color

	func body(content: Content) -> some View {
		content
			.padding()
			.background {
				LinearGradient(
					colors: [
						backgroundColor,
						backgroundColor.opacity(0.6)
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

extension View {
	func cardStyle(backgroundColor: Color) -> some View {
		modifier(CardStyle(backgroundColor: backgroundColor))
	}
}

#Preview {
	Text("Card Style")
		.cardStyle(backgroundColor: .indigo)
}
