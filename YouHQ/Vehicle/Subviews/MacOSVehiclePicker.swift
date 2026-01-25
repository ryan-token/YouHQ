//
//  MacOSVehiclePicker.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct MacOSVehiclePicker: View {
	let vehicles: [Vehicle]
	@Binding var selectedVehicle: Vehicle?

	var body: some View {
		#if os(macOS)
			if vehicles.count > 1 {
				Picker(
					"Choose Vehicle",
					selection: Binding(
						get: { selectedVehicle?.id },
						set: { newID in
							if let vehicle = vehicles.first(where: { $0.id == newID }) {
								selectedVehicle = vehicle
							}
						}
					)
				) {
					ForEach(vehicles) { vehicle in
						Text(vehicle.displayName)
							.tag(vehicle.id)
					}
				}
				.labelsHidden()
			}
		#endif
	}
}
