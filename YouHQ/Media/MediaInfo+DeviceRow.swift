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

		var body: some View {
			DeviceSection(
				device: device,
				onColorChange: updateBackgroundColor,
				onTap: showEditSheet
			)
			.editableRow(id: device.id, onDelete: delete)
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
