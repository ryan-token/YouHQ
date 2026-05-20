//
//  PaywallManager.swift
//  YouHQ
//
//  Created by Ryan Token on 1/31/26.
//

import StoreKit

@Observable
class PaywallManager {
	let subscriptionGroupID = "21913578" // from App Store Connect

	var isShowingPaywallSheet = false
	var isShowingPaywallInSettingsWindow = false
	var needsSettingsDismissalBeforePaywall = false
	private(set) var verifiedActiveSubscriptionIDs = Set<String>()

	@ObservationIgnored
	private var observerTask: Task<Void, Never>?

	@ObservationIgnored
	private var lastEntitlementCheck: Date?

	var hasUnlockedPremium: Bool {
		verifiedActiveSubscriptionIDs.isNotEmpty
	}

	func showPaywall() {
		Analytics.sendSignal(.paywallPresented)
		isShowingPaywallSheet = true
	}

	/// Call this instead of `showPaywall()` when inside SettingsScreen.
	/// On iOS, this dismisses the Settings sheet first so the paywall can present from AppTabView.
	/// On macOS, this presents the paywall in the Settings window only (not the main window).
	func showPaywallFromSettings() {
		Analytics.sendSignal(.paywallPresented)
		#if os(macOS)
		isShowingPaywallInSettingsWindow = true
		#else
		needsSettingsDismissalBeforePaywall = true
		#endif
	}

	func setup() async {
		await setInitialStatus()

		guard observerTask == nil else { return }
		observerTask = Task(priority: .background) {
			for await result in Transaction.updates {
				consumeVerificationResult(for: result)
			}
		}
	}

	func refreshEntitlementsIfNeeded() async {
		guard let lastCheck = lastEntitlementCheck else {
			await refreshEntitlements()
			return
		}

		if Date.now.timeIntervalSince(lastCheck) > 300 {
			await refreshEntitlements()
		}
	}

	private func refreshEntitlements() async {
		await setInitialStatus()
		lastEntitlementCheck = Date.now
	}

	private func setInitialStatus() async {
		for await result in Transaction.currentEntitlements {
			consumeVerificationResult(for: result)
		}
	}

	private func consumeVerificationResult(for result: VerificationResult<Transaction>) {
		guard case .verified(let transaction) = result else { return }
		Analytics.trackPurchase(for: transaction)

		if transaction.revocationDate != nil {
			verifiedActiveSubscriptionIDs.remove(transaction.productID)
		} else if let expirationDate = transaction.expirationDate, expirationDate < Date.now {
			verifiedActiveSubscriptionIDs.remove(transaction.productID)
		} else if transaction.isUpgraded {
			verifiedActiveSubscriptionIDs.remove(transaction.productID)
		} else {
			verifiedActiveSubscriptionIDs.insert(transaction.productID)
		}
	}

	isolated deinit {
		observerTask?.cancel()
	}
}
