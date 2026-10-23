//
//  MediaInfo+ServiceProviderRow.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import SwiftUI

extension MediaInfo {
	struct ServiceProviderRow: View {
		let serviceProvider: ServiceProvider
		let vm: MediaScreen.ViewModel
		@Environment(\.hideMediaCosts) private var hideCosts

		var body: some View {
			ServiceProviderSection(
				serviceProvider: serviceProvider,
				hideCosts: hideCosts,
				onColorChange: updateBackgroundColor,
				onTap: showEditSheet
			)
			.editableRow(id: serviceProvider.id, onDelete: delete)
		}

		private func updateBackgroundColor(_ newColor: Color) {
			vm.serviceProviderViewModel.updateBackgroundColor(newColor, for: serviceProvider)
		}

		private func showEditSheet() {
			vm.showSectionEditSheet(for: .serviceProvider(serviceProvider), sourceID: serviceProvider.id.uuidString)
		}

		private func delete() {
			vm.serviceProviderViewModel.delete(serviceProvider)
		}
	}
}
