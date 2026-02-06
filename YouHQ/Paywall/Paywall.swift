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
	@State private var refreshTrigger = UUID()

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
		.id(refreshTrigger)
		.onAppear {
			refreshTrigger = UUID() // SubscriptionStoreView loses the active plan without this
		}
		.onInAppPurchaseCompletion { _, result in
			if case .success(.success(let transaction)) = result {
				print("Purchased successfully: \(transaction.signedDate)")
				// rain confetti
			} else {
				print("Something went wrong")
			}
		}
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
