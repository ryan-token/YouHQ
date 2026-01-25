//
//  VehicleScreen+AddMoreButton.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

extension VehicleInfo {
	struct AddMoreButton: View {
		let vm: VehicleScreen.ViewModel

		var body: some View {
			Menu {
				VehicleMenu(vm: vm, includeAddVehicle: false)
			} label: {
				HStack {
					Image(systemName: "plus.circle.fill")
						.font(.title2)
					Text("Add More")
						.font(.headline)
				}
				.frame(maxWidth: .infinity)
				.padding()
				.background(.ultraThinMaterial)
				.clipShape(.rect(cornerRadius: 12))
			}
			.buttonStyle(.plain)
			.padding(.bottom)
		}
	}
}

#Preview {
	VehicleInfo.AddMoreButton(vm: VehicleScreen.ViewModel())
}
