//
//  Paywall+MarketingCopy.swift
//  YouHQ
//
//  Created by Ryan Token on 1/31/26.
//

import StoreKit
import SwiftUI

extension Paywall {
	struct MarketingCopy: View {
		@Environment(PaywallManager.self) private var paywallManager

		let shouldShowSkipButton: Bool
		let shouldShowDismissButton: Bool
		let onComplete: (() -> Void)?

		init(shouldShowSkipButton: Bool, shouldShowDismissButton: Bool, onComplete: (() -> Void)? = nil) {
			self.shouldShowSkipButton = shouldShowSkipButton
			self.shouldShowDismissButton = shouldShowDismissButton
			self.onComplete = onComplete
		}

		var body: some View {
			Group {
				if paywallManager.hasUnlockedPremium {
					VStack {
						Header(shouldShowDismissButton: shouldShowDismissButton)
						Spacer()
						ThankYouBadge()
							.animation(.default, value: paywallManager.hasUnlockedPremium)
					}
				} else {
					VStack(spacing: 8) {
						Header(shouldShowDismissButton: shouldShowDismissButton)
						FeatureComparison()
						if shouldShowSkipButton {
							SkipButton(onComplete: onComplete)
						}
						Spacer()
					}
				}
			}
			.foregroundStyle(.white)
			#if os(visionOS)
				.background(PaywallGradient())
			#else
				.containerBackground(for: .subscriptionStoreFullHeight) {
					PaywallGradient()
				}
			#endif
		}
	}
}

#Preview {
	Paywall.MarketingCopy(shouldShowSkipButton: true, shouldShowDismissButton: true)
		.environment(PaywallManager())
}
