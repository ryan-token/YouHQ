//
//  NoVehiclesView.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct NoVehiclesView: View {
	let onAddVehicleTapped: () -> Void

	var body: some View {
		ContentUnavailableView {
			Label("No vehicles", systemImage: "car.2")
		} description: {
			Button("Add vehicle") {
				onAddVehicleTapped()
			}
		}
		.frame(maxWidth: .infinity, alignment: .center)
	}
}

#Preview {
	NoVehiclesView(onAddVehicleTapped: {})
}
