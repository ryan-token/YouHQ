//
//  AppOnboardingFlow+DestinationView.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import SwiftUI

extension AppOnboardingFlow {
	/// The screen pushed for each step after the carousel.
	struct DestinationView: View {
		@Environment(PaywallManager.self) private var paywallManager

		let destination: Destination
		let vm: ViewModel

		var body: some View {
			switch destination {
			case .profileCreation:
				OnboardingProfileCreationView {
					vm.navigationPath.append(.reminder)
				}
			case .reminder:
				OnboardingReminderView {
					vm.navigateAfterReminder(hasUnlockedPremium: paywallManager.hasUnlockedPremium)
				}
			case .paywall:
				OnboardingPaywallStep {
					vm.navigationPath.append(.congratulations)
				}
			case .congratulations:
				OnboardingCongratulationsView()
			}
		}
	}
}
