//
//  ResidenceMapView.swift
//  YouHQ
//
//  Created by Ryan Token on 2/5/26.
//

@preconcurrency import MapKit
import SwiftUI

struct ResidenceMapView: View {
	let residences: [Residence]
	@Binding var selectedResidence: Residence?

	@State private var cameraPosition: MapCameraPosition = .automatic
	@State private var mapLocations: [ResidenceMapLocation] = []
	@State private var selectedMapLocation: ResidenceMapLocation?

	let latLonDelta: CLLocationDegrees = 0.3

	var body: some View {
		Map(position: $cameraPosition, selection: $selectedMapLocation) {
			ForEach(mapLocations) { location in
				let isSelected = location.residence.id == selectedResidence?.id
				Marker(
					location.residence.unitOrStreet ?? "Home",
					systemImage: isSelected ? "house.fill" : "house",
					coordinate: location.coordinate
				)
				.tint(isSelected ? .indigo : .gray)
				.tag(location)
			}
		}
		.frame(height: 200)
		.clipShape(.rect(cornerRadius: 12))
		.task {
			await geocodeResidences()
		}
		.onChange(of: residences) {
			Task {
				await geocodeResidences()
			}
		}
		.onChange(of: selectedMapLocation) {
			if let selectedMapLocation {
				selectedResidence = selectedMapLocation.residence
			}
		}
		.onChange(of: selectedResidence?.id) {
			// Update the map's selection to trigger the animation when residence changes externally
			if let selectedResidence,
				let matchingLocation = mapLocations.first(where: { $0.residence.id == selectedResidence.id })
			{
				selectedMapLocation = matchingLocation
				updateCameraPosition()
			}
		}
	}

	private func geocodeResidences() async {
		var locations: [ResidenceMapLocation] = []

		for residence in residences {
			// Only geocode if we have at least a street and city
			guard residence.street.isNotEmpty, residence.city.isNotEmpty else { continue }

			let address = residence.address
			guard let request = MKGeocodingRequest(addressString: address) else { continue }

			do {
				let mapItems = try await request.mapItems

				if let mapItem = mapItems.first {
					let location = mapItem.location
					let mapLocation = ResidenceMapLocation(
						residence: residence,
						coordinate: location.coordinate
					)
					locations.append(mapLocation)
				}
			} catch {
				// Silently skip residences that can't be geocoded
				continue
			}
		}

		mapLocations = locations

		// Update camera position to zoom into the selected residence
		updateCameraPosition()
	}

	private func updateCameraPosition() {
		// Find the selected residence's location
		if let selectedResidence,
			let selectedLocation = mapLocations.first(where: { $0.residence.id == selectedResidence.id })
		{
			// Zoom into the selected residence with animation
			let region = MKCoordinateRegion(
				center: selectedLocation.coordinate,
				span: MKCoordinateSpan(latitudeDelta: latLonDelta, longitudeDelta: latLonDelta)
			)
			withAnimation {
				cameraPosition = .region(region)
			}
		} else if let firstLocation = mapLocations.first {
			// Fallback to first location if no selection
			let region = MKCoordinateRegion(
				center: firstLocation.coordinate,
				span: MKCoordinateSpan(latitudeDelta: latLonDelta, longitudeDelta: latLonDelta)
			)
			withAnimation {
				cameraPosition = .region(region)
			}
		}
	}
}

// Helper struct to hold geocoded location data
private struct ResidenceMapLocation: Identifiable, Hashable {
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

#Preview {
	let sampleResidences = [
		Residence(
			id: UUID(),
			profileID: UUID(),
			street: "1 Apple Park Way",
			city: "Cupertino",
			state: "CA",
			zipCode: "95014"
		),
		Residence(
			id: UUID(),
			profileID: UUID(),
			street: "1 Infinite Loop",
			city: "Cupertino",
			state: "CA",
			zipCode: "95014"
		)
	]

	ResidenceMapView(
		residences: sampleResidences,
		selectedResidence: .constant(sampleResidences.first)
	)
	.padding()
}
