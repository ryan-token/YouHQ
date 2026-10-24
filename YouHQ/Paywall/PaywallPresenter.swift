//
//  PaywallPresenter.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import Foundation

/// Where and when one window presents the paywall.
///
/// Entitlements are app-wide and live in `PaywallManager`, but presentation belongs to a single
/// window: with two YouHQ windows open (iPad, or iPhone Duo's inner display), a shared flag would
/// show the paywall — or dismiss Settings — in both. Each scene owns one presenter in `@State`
/// and passes it down through the environment.
@Observable
final class PaywallPresenter {
	var isShowingPaywallSheet = false
	var isShowingPaywallInSettingsWindow = false
	var needsSettingsDismissalBeforePaywall = false

	func showPaywall() {
		Analytics.sendSignal(.paywallPresented)
		isShowingPaywallSheet = true
	}

	/// Call this instead of `showPaywall()` when inside SettingsScreen.
	/// On iOS, this dismisses the Settings sheet first so the paywall can present from AppTabView.
	/// On macOS, this presents the paywall in the Settings window only (not the main window).
	func showPaywallFromSettings() {
		#if os(macOS)
			Analytics.sendSignal(.paywallPresented)
			isShowingPaywallInSettingsWindow = true
		#else
			// `showPaywall()` records the presentation once Settings finishes dismissing.
			needsSettingsDismissalBeforePaywall = true
		#endif
	}
}
