//
//  ResidenceMapView.swift
//  YouHQ
//
//  Created by Ryan Token on 2/6/26.
//

import MapKit
import SwiftUI

struct ResidenceMapView: View {
	@Binding var cameraPosition: MapCameraPosition
	let mapLocations: [ResidenceMapLocation]
	let selectedResidence: Residence?
	@Binding var selectedMapLocation: ResidenceMapLocation?
	let showControls: Bool

	var body: some View {
		Map(position: $cameraPosition, interactionModes: [.pan, .zoom], selection: $selectedMapLocation) {
			ForEach(mapLocations) { location in
				ResidenceAnnotation(
					location: location,
					isSelected: location.residence.id == selectedResidence?.id,
					onSelect: { selectedMapLocation = location }
				)
				.tag(location)
			}
		}
		.mapControlVisibility(showControls ? .visible : .hidden)
	}
}

#Preview {
	@Previewable @State var cameraPosition: MapCameraPosition = .automatic
	@Previewable @State var selectedMapLocation: ResidenceMapLocation?

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

	let sampleLocations = [
		ResidenceMapLocation(
			residence: sampleResidences[0],
			coordinate: .init(latitude: 37.3349, longitude: -122.0090)
		),
		ResidenceMapLocation(
			residence: sampleResidences[1],
			coordinate: .init(latitude: 37.3318, longitude: -122.0312)
		)
	]

	ResidenceMapView(
		cameraPosition: $cameraPosition,
		mapLocations: sampleLocations,
		selectedResidence: sampleResidences.first,
		selectedMapLocation: $selectedMapLocation,
		showControls: true
	)
	.frame(height: 400)
	.padding()
}
