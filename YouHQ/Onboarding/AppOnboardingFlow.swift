//
//  AppOnboardingFlow.swift
//  YouHQ
//
//  Created by Ryan Token on 2/7/26.
//

import SwiftUI

struct AppOnboardingFlow: View {
	@Environment(PaywallManager.self) private var paywallManager

	@State private var vm = ViewModel()

	let fromSettings: Bool
	let timeOnEachTab = 4
	let lastAutoAdvanceTab = 5 // Stop auto-advancing after OnboardingSummaryView

	init(fromSettings: Bool = false) {
		self.fromSettings = fromSettings
	}

	var body: some View {
		NavigationStack(path: $vm.navigationPath) {
			OnboardingCarousel(
				vm: vm,
				screenshots: OnboardingScreenshot.appOnboardingScreenshots,
				timeOnEachTab: timeOnEachTab,
				lastAutoAdvanceTab: lastAutoAdvanceTab,
				onSummaryAdvance: { vm.navigationPath.append(.profileCreation) }
			)
			.navigationDestination(for: Destination.self) { destination in
				destinationView(for: destination)
			}
		}
		#if !os(macOS)
			.toolbar(.hidden, for: .navigationBar)
			.overlay(alignment: .topLeading) {
				if fromSettings && UIDevice.current.userInterfaceIdiom == .phone {
					OnboardingBackButton()
					.padding()
				}
			}
		#endif
		.task {
			await paywallManager.refreshEntitlementsIfNeeded()
		}
	}

	@ViewBuilder
	private func destinationView(for destination: Destination) -> some View {
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

#Preview {
	struct AppOnboardingPreview: View {
		@State private var paywallManager = PaywallManager()

		var body: some View {
			NavigationStack {
				AppOnboardingFlow()
					.environment(paywallManager)
			}
		}
	}
	return AppOnboardingPreview()
}
