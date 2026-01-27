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
				AddMoreButtonLabel(text: "Add More")
			}
			.buttonStyle(.plain)
			.padding(.bottom)
		}
	}
}

#Preview {
	VehicleInfo.AddMoreButton(vm: VehicleScreen.ViewModel())
}
