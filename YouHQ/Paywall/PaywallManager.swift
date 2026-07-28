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

	@ObservationIgnored
	private var refreshGeneration = 0

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
		observeTransactionUpdates()
		// Entitlements first: until they load a paying customer sees a paywall, whereas the
		// backlog drain only matters once, on the first launch after updating.
		await refreshEntitlements()
		await finishOutstandingTransactions()
	}

	/// Starts observing before the first `await`. `setup()` runs from a `task(id: scenePhase)`,
	/// so it can be cancelled partway through, and losing the observer would mean missing
	/// renewals and purchases made on the customer's other devices.
	private func observeTransactionUpdates() {
		guard observerTask == nil else { return }
		observerTask = Task { [weak self] in
			for await result in Transaction.updates {
				guard let self else { return }
				await self.record(result)
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

	/// Records a transaction the App Store handed us and finishes it, reporting whether
	/// premium is unlocked once it has been applied.
	///
	/// Finishing tells the App Store the service is enabled. An unfinished transaction stays
	/// in the queue, where it gets handed back from the next purchase attempt, so subscribing
	/// appears to succeed instantly while unlocking nothing, and replayed on launch through
	/// `Transaction.updates`, so the app unlocks for someone who never bought anything.
	@discardableResult
	func record(_ result: VerificationResult<Transaction>) async -> Bool {
		// Finish even when the payload fails verification, and unlock nothing. Finishing is
		// not granting: it only tells the App Store to stop redelivering. Leaving one queued
		// jams the purchase flow for good, because the App Store keeps handing it back in
		// place of the purchase the customer is trying to make.
		guard case .verified(let transaction) = result else {
			await result.unsafePayloadValue.finish()
			return false
		}

		if transaction.revocationDate == nil {
			Analytics.trackPurchase(for: transaction)
		}
		await transaction.finish()

		await refreshEntitlements()
		apply(transaction)
		return verifiedActiveSubscriptionIDs.contains(transaction.productID)
	}

	/// Applies a transaction on top of the sweep's answer.
	///
	/// A transaction in hand is the better authority on its own product: the sweep can be
	/// cancelled, and it can run before `currentEntitlements` reflects a purchase that just
	/// completed, either of which would otherwise lose a purchase the customer was charged
	/// for. Expiry is the exception and is left to the sweep, because a lapsed subscription
	/// and one inside its billing grace period are indistinguishable from here.
	private func apply(_ transaction: Transaction) {
		if transaction.revocationDate != nil || transaction.isUpgraded {
			verifiedActiveSubscriptionIDs.remove(transaction.productID)
		} else if transaction.expirationDate.map({ $0 > Date.now }) ?? true {
			verifiedActiveSubscriptionIDs.insert(transaction.productID)
		}
	}

	/// Rebuilds the unlocked set from the App Store's current entitlements.
	///
	/// Replaces the set rather than adding to it: `currentEntitlements` drops a lapsed
	/// subscription instead of emitting an expired copy of it, so an insert-only set would
	/// stay unlocked for the rest of the process.
	func refreshEntitlements() async {
		// Several callers can be sweeping at once, and a purchase always produces at least
		// two. Only the newest may commit, or a sweep that began before the purchase would
		// overwrite it with a snapshot that predates it and re-lock the app.
		refreshGeneration += 1
		let generation = refreshGeneration

		var active = Set<String>()
		for await result in Transaction.currentEntitlements {
			guard case .verified(let transaction) = result else { continue }
			// Take what the App Store vouches for. It already excludes expired, refunded, and
			// revoked purchases, and it deliberately still includes a subscription in its
			// billing grace period, whose `expirationDate` is in the past for the whole grace
			// window. Re-checking that date here would lock out a customer Apple is still
			// collecting from. Only a superseded upgrade needs dropping.
			guard !transaction.isUpgraded else { continue }
			active.insert(transaction.productID)
		}

		// A cancelled iteration stops early, which is indistinguishable from owning nothing.
		guard !Task.isCancelled, generation == refreshGeneration else { return }

		verifiedActiveSubscriptionIDs = active
		lastEntitlementCheck = Date.now
	}

	/// Drains the backlog of transactions earlier versions delivered but never finished, which
	/// anyone updating from one of those still carries.
	private func finishOutstandingTransactions() async {
		for await result in Transaction.unfinished {
			await result.unsafePayloadValue.finish()
		}
	}

	isolated deinit {
		observerTask?.cancel()
	}
}
