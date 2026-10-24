//
//  ResidenceAnnotation.swift
//  YouHQ
//
//  Created by Ryan Token on 2/6/26.
//

import MapKit
import SwiftUI

struct ResidenceAnnotation: MapContent {
	let location: ResidenceMapLocation
	let isSelected: Bool
	@Binding var selection: ResidenceMapLocation?

	private var title: String {
		location.residence.unitOrStreet ?? "Home"
	}

	var body: some MapContent {
		Annotation(title, coordinate: location.coordinate) {
			ResidenceAnnotationLabel(
				location: location,
				title: title,
				isSelected: isSelected,
				selection: $selection
			)
		}
	}
}
