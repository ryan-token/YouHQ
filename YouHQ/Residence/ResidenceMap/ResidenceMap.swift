//
//  ResidenceMap.swift
//  YouHQ
//
//  Created by Ryan Token on 2/5/26.
//

import SwiftUI

struct ResidenceMap: View {
	let residences: [Residence]
	@Binding var selectedResidence: Residence?
	@Namespace private var namespace
	@State private var vm = ViewModel()

	var body: some View {
		Button {
			vm.isShowingFullScreenMap = true
		} label: {
			ResidenceMapView(
				cameraPosition: $vm.cameraPosition,
				mapLocations: vm.mapLocations,
				selectedResidence: selectedResidence,
				selectedMapLocation: $vm.selectedMapLocation,
				showControls: false
			)
			.frame(height: vm.mapHeight)
			.clipShape(.rect(cornerRadius: 12))
		}
		.buttonStyle(.plain)
		.accessibilityLabel("Open full-screen map")
		.matchedTransitionSource(id: "residenceMap", in: namespace)
		// Re-geocodes on appear and whenever the residences change, cancelling any lookup still in
		// flight. Selection changes only move the camera, via `syncSelection` below.
		.task(id: residences) {
			await vm.geocodeResidences(residences, selectedResidenceId: selectedResidence?.id)
		}
		.onChange(of: vm.selectedMapLocation) { _, newLocation in
			if let newLocation {
				selectedResidence = newLocation.residence
			}
		}
		.onChange(of: selectedResidence?.id) {
			vm.syncSelection(with: selectedResidence?.id)
		}
		.sheet(isPresented: $vm.isShowingFullScreenMap) {
			FullScreenMapView(
				mapLocations: vm.mapLocations,
				selectedResidence: $selectedResidence,
				selectedMapLocation: $vm.selectedMapLocation,
				cameraPosition: vm.cameraPosition,
				latLonDelta: vm.latLonDelta
			)
			#if !os(macOS)
				.navigationTransition(.zoom(sourceID: "residenceMap", in: namespace))
			#endif
		}
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

	ResidenceMap(
		residences: sampleResidences,
		selectedResidence: .constant(sampleResidences.first)
	)
	.padding()
}
