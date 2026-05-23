//
//  NoVehiclesView.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct NoVehiclesView: View {
	@Environment(\.sheetNamespace) private var namespace
	let onAddVehicleTapped: () -> Void

	var body: some View {
		ContentUnavailableView {
			Label("No vehicles", systemImage: "car.2")
		} description: {
			Button("Add vehicle") {
				onAddVehicleTapped()
			}
			.matchedTransitionSource(id: "emptyStateButton", in: namespace)
		}
		.frame(maxWidth: .infinity, alignment: .center)
	}
}

#Preview {
	NoVehiclesView(onAddVehicleTapped: {})
}
