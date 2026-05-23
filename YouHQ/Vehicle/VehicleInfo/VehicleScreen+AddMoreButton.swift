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
		@Environment(\.sheetNamespace) private var namespace

		var body: some View {
			Menu {
				VehicleMenu(vm: vm, includeAddVehicle: false, sourceID: "addMoreButton")
			} label: {
				AddMoreButtonLabel(text: "Add More")
			}
			.buttonStyle(.plain)
			.padding(.bottom)
			.matchedTransitionSource(id: "addMoreButton", in: namespace)
		}
	}
}

#Preview {
	VehicleInfo.AddMoreButton(vm: VehicleScreen.ViewModel())
}
