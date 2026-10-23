//
//  MediaInfo+DeviceRow.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import SwiftUI

extension MediaInfo {
	struct DeviceRow: View {
		let device: Device
		let vm: MediaScreen.ViewModel
		@Environment(\.sheetNamespace) private var namespace

		var body: some View {
			DeviceSection(
				device: device,
				onColorChange: updateBackgroundColor,
				onTap: showEditSheet
			)
			.matchedTransitionSource(id: device.id.uuidString, in: namespace)
			.swipeActions(edge: .trailing, allowsFullSwipe: true) {
				Button("Delete", systemImage: "trash", role: .destructive, action: delete)
			}
		}

		private func updateBackgroundColor(_ newColor: Color) {
			vm.deviceViewModel.updateBackgroundColor(newColor, for: device)
		}

		private func showEditSheet() {
			vm.showSectionEditSheet(for: .device(device), sourceID: device.id.uuidString)
		}

		private func delete() {
			vm.deviceViewModel.delete(device)
		}
	}
}
