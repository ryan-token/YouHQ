//
//  MediaMenu.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct MediaMenu: View {
	let vm: MediaScreen.ViewModel
	let sourceID: String

	init(vm: MediaScreen.ViewModel, sourceID: String = "addButton") {
		self.vm = vm
		self.sourceID = sourceID
	}

	var body: some View {
		PaywalledButton(
			title: "Add Service Provider",
			systemImage: "network",
			currentCount: vm.mediaItemsCount,
			threshold: Constants.paywallCoreItemsThreshold
		) {
			vm.showAddServiceProviderSheet(sourceID: sourceID)
		}

		PaywalledButton(
			title: "Add Subscription",
			systemImage: "rectangle.stack",
			currentCount: vm.mediaItemsCount,
			threshold: Constants.paywallCoreItemsThreshold
		) {
			vm.showAddSubscriptionSheet(sourceID: sourceID)
		}

		PaywalledButton(
			title: "Add Device",
			systemImage: "desktopcomputer",
			currentCount: vm.mediaItemsCount,
			threshold: Constants.paywallCoreItemsThreshold
		) {
			vm.showAddDeviceSheet(sourceID: sourceID)
		}

		PaywalledButton(
			title: "Add Other",
			systemImage: "ellipsis.circle.fill",
			currentCount: vm.mediaItemsCount,
			threshold: Constants.paywallCoreItemsThreshold
		) {
			vm.showAddOtherSheet(sourceID: sourceID)
		}
	}
}
