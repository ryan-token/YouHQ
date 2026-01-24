//
//  PaintColorsNavButton.swift
//  YouHQ
//
//  Created by Ryan Token on 1/20/26.
//

import SwiftUI

struct PaintColorsNavButton: View {
	@Binding var isNavigating: Bool
	let paintColors: [RoomPaintColor]

	var body: some View {
		Button {
			isNavigating = true
		} label: {
			HStack {
				Image(systemName: "paintbrush.fill")
					.font(.title2)

				VStack(alignment: .leading, spacing: 4) {
					Text("Paint Colors")
						.font(.headline)

					Text("^[\(paintColors.count) color](inflect: true)")
						.font(.subheadline)
						.opacity(0.8)
				}

				Spacer()

				Image(systemName: "chevron.right")
					.font(.body.weight(.semibold))
					.foregroundStyle(.white.opacity(0.6))
			}
			.padding()
			.background(
				LinearGradient(
					gradient: Gradient(colors: [.purple, .pink]),
					startPoint: .leading,
					endPoint: .trailing
				)
			)
			.foregroundStyle(.white)
			.clipShape(.rect(cornerRadius: 12))
		}
		.buttonStyle(.plain)
		.padding(.bottom)
	}
}
