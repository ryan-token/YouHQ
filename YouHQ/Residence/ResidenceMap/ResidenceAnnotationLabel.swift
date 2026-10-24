//
//  ResidenceAnnotationLabel.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import SwiftUI

/// The house button drawn for one residence on the map.
struct ResidenceAnnotationLabel: View {
	let location: ResidenceMapLocation
	let title: String
	let isSelected: Bool
	@Binding var selection: ResidenceMapLocation?

	var body: some View {
		Button(title, systemImage: isSelected ? "house.fill" : "house", action: select)
			.labelStyle(.iconOnly)
			.foregroundStyle(isSelected ? .indigo : .gray)
			.font(.title2)
			.padding(8)
			.background(.regularMaterial, in: .circle)
			.buttonStyle(.plain)
			.accessibilityAddTraits(isSelected ? .isSelected : [])
	}

	private func select() {
		selection = location
	}
}
