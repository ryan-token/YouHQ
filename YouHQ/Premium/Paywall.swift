//
//  Paywall.swift
//  YouHQ
//
//  Created by Ryan Token on 1/31/26.
//

import StoreKit
import SwiftUI

struct Paywall: View {
	@Environment(PaywallManager.self) private var paywallManager
	let fromSettings: Bool

	init(fromSettings: Bool = false) {
		self.fromSettings = fromSettings
	}

    var body: some View {
		SubscriptionStoreView(groupID: paywallManager.subscriptionGroupID) {
			MarketingCopy()
		}
		.if(fromSettings) {
			$0.storeButton(.hidden, for: .cancellation)
		}
		.storeButton(.visible, for: .restorePurchases)
    }
}

#Preview {
	struct PaywallPreview: View {
		@State private var paywallManager = PaywallManager()

		var body: some View {
			Paywall()
				.environment(paywallManager)
		}
	}
	return PaywallPreview()
}
