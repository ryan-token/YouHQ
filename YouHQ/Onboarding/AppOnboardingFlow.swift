//
//  AppOnboardingFlow.swift
//  YouHQ
//
//  Created by Ryan Token on 2/7/26.
//

import SwiftUI

struct AppOnboardingFlow: View {
	@Environment(PaywallManager.self) private var paywallManager
	#if !os(macOS)
		@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	#endif

	@State private var vm = ViewModel()

	let fromSettings: Bool
	private let timeOnEachTab = 4
	private let lastAutoAdvanceTab = 5 // Stop auto-advancing after OnboardingSummaryView

	init(fromSettings: Bool = false) {
		self.fromSettings = fromSettings
	}

	var body: some View {
		NavigationStack(path: $vm.navigationPath) {
			OnboardingCarousel(
				vm: vm,
				timeOnEachTab: timeOnEachTab,
				lastAutoAdvanceTab: lastAutoAdvanceTab,
				onSummaryAdvance: { vm.navigationPath.append(.profileCreation) }
			)
			.navigationDestination(for: Destination.self) { destination in
				DestinationView(destination: destination, vm: vm)
			}
		}
		#if !os(macOS)
			.toolbar(.hidden, for: .navigationBar)
			.overlay(alignment: .topLeading) {
				if showsBackButton {
					OnboardingBackButton()
					.padding()
				}
			}
		#endif
		.task {
			await paywallManager.refreshEntitlementsIfNeeded()
		}
	}

	#if !os(macOS)
		/// From Settings, the flow is pushed onto a collapsed split view whose navigation bar it
		/// hides, so it needs its own way back. When the split view shows the sidebar beside it
		/// (regular width), the sidebar already provides that.
		private var showsBackButton: Bool {
			fromSettings && horizontalSizeClass != .regular
		}
	#endif
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
