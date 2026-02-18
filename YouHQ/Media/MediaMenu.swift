//
//  MediaMenu.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct MediaMenu: View {
	@Environment(PaywallManager.self) private var paywallManager

	let vm: MediaScreen.ViewModel
	let sourceID: String

	init(vm: MediaScreen.ViewModel, sourceID: String = "addButton") {
		self.vm = vm
		self.sourceID = sourceID
	}

	var body: some View {
		Button {
			if paywallManager.hasUnlockedPremium || vm.mediaItemsCount < Constants.paywallCoreItemsThreshold {
				vm.showAddServiceProviderSheet(sourceID: sourceID)
			} else {
				paywallManager.showPaywall()
			}
		} label: {
			Label("Add Service Provider", systemImage: "network")
		}

		Button {
			if paywallManager.hasUnlockedPremium || vm.mediaItemsCount < Constants.paywallCoreItemsThreshold {
				vm.showAddSubscriptionSheet(sourceID: sourceID)
			} else {
				paywallManager.showPaywall()
			}
		} label: {
			Label("Add Subscription", systemImage: "rectangle.stack")
		}

		Button {
			if paywallManager.hasUnlockedPremium || vm.mediaItemsCount < Constants.paywallCoreItemsThreshold {
				vm.showAddDeviceSheet(sourceID: sourceID)
			} else {
				paywallManager.showPaywall()
			}
		} label: {
			Label("Add Device", systemImage: "desktopcomputer")
		}

		Button {
			if paywallManager.hasUnlockedPremium || vm.mediaItemsCount < Constants.paywallCoreItemsThreshold {
				vm.showAddOtherSheet(sourceID: sourceID)
			} else {
				paywallManager.showPaywall()
			}
		} label: {
			Label("Add Other", systemImage: "ellipsis.circle.fill")
		}
	}
}
