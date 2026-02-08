//
//  ResidenceMap+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 2/6/26.
//

@preconcurrency import MapKit
import SwiftUI

extension ResidenceMap {
	@Observable
	class ViewModel {
		var cameraPosition: MapCameraPosition = .automatic
		var mapLocations: [ResidenceMapLocation] = []
		var selectedMapLocation: ResidenceMapLocation?
		var isShowingFullScreenMap = false

		let mapHeight: CGFloat = 200
		let latLonDelta: CLLocationDegrees = 0.25

		func geocodeResidences(_ residences: [Residence], selectedResidenceId: UUID? = nil) async {
			var locations: [ResidenceMapLocation] = []

			await withTaskGroup(of: ResidenceMapLocation?.self) { group in
				for residence in residences where residence.street.isNotEmpty && residence.city.isNotEmpty {
					group.addTask {
						await self.geocode(residence)
					}
				}

				for await location in group.compactMap({ $0 }) {
					locations.append(location)
				}
			}

			mapLocations = locations
			syncSelection(with: selectedResidenceId)
		}

		private func geocode(_ residence: Residence) async -> ResidenceMapLocation? {
			guard let request = MKGeocodingRequest(addressString: residence.address),
				let mapItem = try? await request.mapItems.first
			else {
				return nil
			}

			return ResidenceMapLocation(
				residence: residence,
				coordinate: mapItem.location.coordinate
			)
		}

		func syncSelection(with selectedResidenceId: UUID?) {
			guard let selectedResidenceId,
				let matchingLocation = mapLocations.first(where: { $0.residence.id == selectedResidenceId })
			else {
				updateCameraToFirstLocation()
				return
			}

			selectedMapLocation = matchingLocation
			updateCamera(to: matchingLocation.coordinate)
		}

		func updateCamera(to coordinate: CLLocationCoordinate2D) {
			let region = MKCoordinateRegion(
				center: coordinate,
				span: MKCoordinateSpan(latitudeDelta: latLonDelta, longitudeDelta: latLonDelta)
			)
			withAnimation {
				cameraPosition = .region(region)
			}
		}

		private func updateCameraToFirstLocation() {
			guard let firstLocation = mapLocations.first else { return }
			updateCamera(to: firstLocation.coordinate)
		}
	}
}
