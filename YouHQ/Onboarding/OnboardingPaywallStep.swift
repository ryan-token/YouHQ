//
//  OnboardingPaywallStep.swift
//  YouHQ
//
//  Created by Ryan Token on 5/20/26.
//

import SwiftUI

/// Wraps `Paywall` with the platform-specific framing used during onboarding.
struct OnboardingPaywallStep: View {
	let onComplete: () -> Void

	var body: some View {
		#if os(macOS)
			ScrollView {
				Paywall(
					fromOnboarding: true,
					shouldShowSkipButton: true,
					shouldShowDismissButton: false,
					onComplete: onComplete
				)
			}
		#else
			Paywall(
				fromOnboarding: true,
				shouldShowSkipButton: true,
				shouldShowDismissButton: false,
				onComplete: onComplete
			)
			.background(PaywallGradient())
		#endif
	}
}
