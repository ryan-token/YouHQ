//
//  ResidenceMapModels.swift
//  YouHQ
//
//  Created by Ryan Token on 2/6/26.
//

import Foundation
import MapKit
import SwiftUI

struct ResidenceAnnotation: MapContent {
	let location: ResidenceMapLocation
	let isSelected: Bool
	let onSelect: () -> Void

	var body: some MapContent {
		Annotation(
			location.residence.unitOrStreet ?? "Home",
			coordinate: location.coordinate
		) {
			Button(action: onSelect) {
				Image(systemName: isSelected ? "house.fill" : "house")
					.foregroundStyle(isSelected ? .indigo : .gray)
					.font(.title2)
					.padding(8)
					.background(.regularMaterial, in: .circle)
			}
			.buttonStyle(.plain)
		}
	}
}

struct ResidenceMapLocation: Identifiable, Hashable {
	let id: UUID
	let residence: Residence
	let coordinate: CLLocationCoordinate2D

	init(residence: Residence, coordinate: CLLocationCoordinate2D) {
		self.id = residence.id
		self.residence = residence
		self.coordinate = coordinate
	}

	static func == (lhs: ResidenceMapLocation, rhs: ResidenceMapLocation) -> Bool {
		lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
