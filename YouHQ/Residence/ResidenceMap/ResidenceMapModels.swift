//
//  ResidenceMapModels.swift
//  YouHQ
//
//  Created by Ryan Token on 2/6/26.
//

import MapKit

struct ResidenceMapLocation: Identifiable, Hashable {
	let residence: Residence
	let coordinate: CLLocationCoordinate2D

	var id: UUID { residence.id }

	static func == (lhs: ResidenceMapLocation, rhs: ResidenceMapLocation) -> Bool {
		lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
