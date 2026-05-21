//
//  PaywalledButton.swift
//  YouHQ
//
//  Created by Ryan Token on 5/20/26.
//

import SwiftUI

/// A `Button` whose action is gated behind the paywall once `currentCount` reaches `threshold`.
///
/// Used both inside `Add` menus (Residence/Vehicle/Money/Media/Career) and as standalone toolbar
/// buttons. Premium users always run the action; free users run it only while under the threshold,
/// otherwise see the paywall.
struct PaywalledButton: View {
	@Environment(PaywallManager.self) private var paywallManager

	let title: String
	let systemImage: String
	let currentCount: Int
	let threshold: Int
	let action: () -> Void

	var body: some View {
		Button {
			if paywallManager.hasUnlockedPremium || currentCount < threshold {
				action()
			} else {
				paywallManager.showPaywall()
			}
		} label: {
			Label(title, systemImage: systemImage)
		}
	}
}
