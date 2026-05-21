//
//  PaywalledMenuButton.swift
//  YouHQ
//
//  Created by Ryan Token on 5/20/26.
//

import SwiftUI

/// A menu `Button` that gates its action behind the paywall once `currentCount` reaches `threshold`.
///
/// Used in the `Add` menus on each tab (Residence/Vehicle/Money/Media/Career). Premium users always
/// run the action; free users run it only while under the threshold, otherwise see the paywall.
struct PaywalledMenuButton: View {
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
