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
		@Environment(\.hideMediaCosts) private var hideCosts

		var body: some View {
			OtherSection(
				other: other,
				hideCosts: hideCosts,
				onColorChange: updateBackgroundColor,
				onTap: showEditSheet
			)
			.editableRow(id: other.id, onDelete: delete)
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
