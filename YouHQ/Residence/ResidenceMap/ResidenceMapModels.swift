//
//  ResidenceMapModels.swift
//  YouHQ
//
//  Created by Ryan Token on 2/6/26.
//

import MapKit

struct ResidenceMapLocation: Identifiable, Hashable {
	let id: UUID
	let residence: Residence
	let coordinate: CLLocationCoordinate2D

	// Kept in the main definition so every location takes its `id` from its residence;
	// a synthesized memberwise initializer would let the two disagree.
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
