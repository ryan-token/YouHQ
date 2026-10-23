//
//  MediaInfo+SubscriptionRow.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import SwiftUI

extension MediaInfo {
	struct SubscriptionRow: View {
		let subscription: Subscription
		let vm: MediaScreen.ViewModel
		@Environment(\.hideMediaCosts) private var hideCosts

		var body: some View {
			SubscriptionSection(
				subscription: subscription,
				hideCosts: hideCosts,
				onColorChange: updateBackgroundColor,
				onTap: showEditSheet
			)
			.editableRow(id: subscription.id, onDelete: delete)
		}

		private func updateBackgroundColor(_ newColor: Color) {
			vm.subscriptionViewModel.updateBackgroundColor(newColor, for: subscription)
		}

		private func showEditSheet() {
			vm.showSectionEditSheet(for: .subscription(subscription), sourceID: subscription.id.uuidString)
		}

		private func delete() {
			vm.subscriptionViewModel.delete(subscription)
		}
	}
}
