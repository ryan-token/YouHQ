//
//  FullScreenMapView.swift
//  YouHQ
//
//  Created by Ryan Token on 2/6/26.
//

import MapKit
import SwiftUI

struct FullScreenMapView: View {
	let mapLocations: [ResidenceMapLocation]
	@Binding var selectedResidence: Residence?
	@Binding var selectedMapLocation: ResidenceMapLocation?

	@State private var cameraPosition: MapCameraPosition
	let latLonDelta: CLLocationDegrees

	@Environment(\.dismiss) private var dismiss

	init(
		mapLocations: [ResidenceMapLocation],
		selectedResidence: Binding<Residence?>,
		selectedMapLocation: Binding<ResidenceMapLocation?>,
		cameraPosition: MapCameraPosition,
		latLonDelta: CLLocationDegrees
	) {
		self.mapLocations = mapLocations
		_selectedResidence = selectedResidence
		_selectedMapLocation = selectedMapLocation
		_cameraPosition = State(initialValue: cameraPosition)
		self.latLonDelta = latLonDelta
	}

	var body: some View {
		NavigationStack {
			ResidenceMapView(
				cameraPosition: $cameraPosition,
				mapLocations: mapLocations,
				selectedResidence: selectedResidence,
				selectedMapLocation: $selectedMapLocation,
				showControls: true
			)
			.navigationTitle("Residences")
			#if !os(macOS)
				.navigationBarTitleDisplayMode(.inline)
			#endif
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button("Done", action: dismiss.callAsFunction)
				}
			}
			.onChange(of: selectedMapLocation) { _, newLocation in
				if let newLocation {
					selectedResidence = newLocation.residence
					updateCamera(to: newLocation.coordinate)
				}
			}
		}
	}

	private func updateCamera(to coordinate: CLLocationCoordinate2D) {
		let region = MKCoordinateRegion(
			center: coordinate,
			span: MKCoordinateSpan(latitudeDelta: latLonDelta, longitudeDelta: latLonDelta)
		)
		withAnimation {
			cameraPosition = .region(region)
		}
	}
}
