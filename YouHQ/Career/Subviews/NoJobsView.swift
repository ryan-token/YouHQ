//
//  NoJobsView.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

extension CareerScreen {
	struct NoJobsView: View {
		let vm: ViewModel
		@Environment(\.sheetNamespace) private var namespace

		var body: some View {
			ContentUnavailableView {
				Label("No jobs", systemImage: "briefcase")
			} description: {
				Menu("Add Job") {
					CareerMenu(vm: vm, sourceID: "emptyStateButton")
				}
				.matchedTransitionSource(id: "emptyStateButton", in: namespace)
			}
			.frame(maxWidth: .infinity, alignment: .center)
		}
	}
}

#Preview {
	CareerScreen.NoJobsView(vm: CareerScreen.ViewModel())
}
