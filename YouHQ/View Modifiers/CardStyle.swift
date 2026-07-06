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
			.legibleForeground(on: backgroundColor)
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
			// Inset so the enclosing List row doesn't clip the shadow — most
			// visible on light cards, where the shadow alone defines the edge.
			.padding(.horizontal, 8)
			.padding(.bottom)
	}
}

extension View {
	func cardStyle(backgroundColor: Color) -> some View {
		modifier(CardStyle(backgroundColor: backgroundColor))
	}
}

#Preview {
	List {
		Group {
			HQText("White card")
				.frame(maxWidth: .infinity, alignment: .leading)
				.cardStyle(backgroundColor: .white)
			HQText("Colored card")
				.frame(maxWidth: .infinity, alignment: .leading)
				.cardStyle(backgroundColor: .indigo)
		}
		.listRowSeparator(.hidden)
		.listRowBackground(Color.clear)
	}
	.scrollContentBackground(.hidden)
}
