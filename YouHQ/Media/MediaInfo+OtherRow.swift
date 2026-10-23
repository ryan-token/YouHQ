//
//  MediaInfo+OtherRow.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import SwiftUI

extension MediaInfo {
	struct OtherRow: View {
		let other: Other
		let vm: MediaScreen.ViewModel
		@Environment(\.sheetNamespace) private var namespace
		@Environment(\.hideMediaCosts) private var hideCosts

		var body: some View {
			OtherSection(
				other: other,
				hideCosts: hideCosts,
				onColorChange: updateBackgroundColor,
				onTap: showEditSheet
			)
			.matchedTransitionSource(id: other.id.uuidString, in: namespace)
			.swipeActions(edge: .trailing, allowsFullSwipe: true) {
				Button("Delete", systemImage: "trash", role: .destructive, action: delete)
			}
		}

		private func updateBackgroundColor(_ newColor: Color) {
			vm.otherViewModel.updateBackgroundColor(newColor, for: other)
		}

		private func showEditSheet() {
			vm.showSectionEditSheet(for: .other(other), sourceID: other.id.uuidString)
		}

		private func delete() {
			vm.otherViewModel.delete(other)
		}
	}
}
