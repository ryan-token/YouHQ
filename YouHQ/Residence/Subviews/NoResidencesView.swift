//
//  NoResidencesView.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct NoResidencesView: View {
	@State private var loadDelayFinished = false
	@Environment(\.sheetNamespace) private var namespace
	let isSynchronizing: Bool
	let onAddResidenceTapped: () -> Void

	var body: some View {
		VStack {
			if isSynchronizing || !loadDelayFinished {
				ProgressView()
					.controlSize(.extraLarge)
			} else {
				ContentUnavailableView {
					Label("No residences", systemImage: "house")
				} description: {
					Button("Add residence") {
						onAddResidenceTapped()
					}
					.matchedTransitionSource(id: "emptyStateButton", in: namespace)
				}
			}
		}
		.frame(maxWidth: .infinity, alignment: .center)
		.task {
			try? await Task.sleep(for: .seconds(0.5))
			withAnimation {
				loadDelayFinished = true
			}
		}
	}
}

#Preview {
	NoResidencesView(isSynchronizing: false, onAddResidenceTapped: {})
}
