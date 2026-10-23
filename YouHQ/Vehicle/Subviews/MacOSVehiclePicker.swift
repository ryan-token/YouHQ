//
//  MacOSVehiclePicker.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct MacOSVehiclePicker: View {
	// Read only in the `#if os(macOS)` body below; an iOS-only scan sees the
	// assignment but not the read.
	// periphery:ignore
	let vehicles: [Vehicle]
	// The owner ignores writes of IDs that don't match a vehicle; see
	// `VehicleScreen.ViewModel.pickerSelectedVehicleID`.
	@Binding var selectedVehicleID: Vehicle.ID?

	var body: some View {
		#if os(macOS)
			if vehicles.count > 1 {
				Picker("Choose Vehicle", selection: $selectedVehicleID) {
					ForEach(vehicles) { vehicle in
						HQText(vehicle.displayName)
							.tag(vehicle.id)
					}
				}
				.labelsHidden()
			}
		#endif
	}
}
