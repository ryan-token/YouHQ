//
//  NoResidencesView.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct NoResidencesView: View {
	@Environment(\.sheetNamespace) private var namespace
	let onAddResidenceTapped: () -> Void

	var body: some View {
		ContentUnavailableView {
			Label("No residences", systemImage: "house")
		} description: {
			Button("Add residence") {
				onAddResidenceTapped()
			}
			.matchedTransitionSource(id: "emptyStateButton", in: namespace)
		}
		.frame(maxWidth: .infinity, alignment: .center)
	}
}

#Preview {
	NoResidencesView(onAddResidenceTapped: {})
}
