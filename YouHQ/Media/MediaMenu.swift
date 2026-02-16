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

	var body: some View {
		Button {
			if paywallManager.hasUnlockedPremium || vm.mediaItemsCount < Constants.paywallCoreItemsThreshold {
				vm.showAddServiceProviderSheet()
			} else {
				paywallManager.showPaywall()
			}
		} label: {
			Label("Add Service Provider", systemImage: "network")
		}

		Button {
			if paywallManager.hasUnlockedPremium || vm.mediaItemsCount < Constants.paywallCoreItemsThreshold {
				vm.showAddSubscriptionSheet()
			} else {
				paywallManager.showPaywall()
			}
		} label: {
			Label("Add Subscription", systemImage: "rectangle.stack")
		}

		Button {
			if paywallManager.hasUnlockedPremium || vm.mediaItemsCount < Constants.paywallCoreItemsThreshold {
				vm.showAddDeviceSheet()
			} else {
				paywallManager.showPaywall()
			}
		} label: {
			Label("Add Device", systemImage: "desktopcomputer")
		}

		Button {
			if paywallManager.hasUnlockedPremium || vm.mediaItemsCount < Constants.paywallCoreItemsThreshold {
				vm.showAddOtherSheet()
			} else {
				paywallManager.showPaywall()
			}
		} label: {
			Label("Add Other", systemImage: "ellipsis.circle.fill")
		}
	}
}
