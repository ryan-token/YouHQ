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

	@State private var vm: ViewModel

	init(residences: [Residence], selectedResidence: Binding<Residence?>) {
		self.residences = residences
		_selectedResidence = selectedResidence
		_vm = State(wrappedValue: ViewModel(residences: residences))
	}

	var body: some View {
		ResidenceMapView(
			cameraPosition: $vm.cameraPosition,
			mapLocations: vm.mapLocations,
			selectedResidence: selectedResidence,
			selectedMapLocation: $vm.selectedMapLocation,
			showControls: false
		)
		.frame(height: vm.mapHeight)
		.clipShape(.rect(cornerRadius: 12))
		.contentShape(.rect)
		.onTapGesture {
			vm.isShowingFullScreenMap = true
		}
		.task {
			await vm.geocodeResidences(selectedResidenceId: selectedResidence?.id)
		}
		.onChange(of: residences) {
			Task { await vm.geocodeResidences(selectedResidenceId: selectedResidence?.id) }
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
