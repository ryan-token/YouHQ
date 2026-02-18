//
//  MediaScreen+NoMediaView.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

extension MediaScreen {
	struct NoMediaView: View {
		let vm: ViewModel

		@Environment(\.sheetNamespace) private var namespace

		var body: some View {
			ContentUnavailableView {
				Label("No media", systemImage: "desktopcomputer.and.macbook")
			} description: {
				Menu("Add Media") {
					MediaMenu(vm: vm, sourceID: "emptyStateButton")
				}
				.matchedTransitionSource(id: "emptyStateButton", in: namespace)
			}
			.frame(maxWidth: .infinity, alignment: .center)
		}
	}
}

#Preview {
	MediaScreen.NoMediaView(vm: MediaScreen.ViewModel())
}
