//
//  PaywallManager.swift
//  YouHQ
//
//  Created by Ryan Token on 1/31/26.
//

import StoreKit

@Observable
class PaywallManager {
	let groupID = "21913578"

	var isShowingPaywallSheet = false
	private(set) var verifiedActiveSubscriptionIDs = Set<String>()

	@ObservationIgnored
	private var observerTask: Task<Void, Never>?

	var hasUnlockedPremium: Bool {
		verifiedActiveSubscriptionIDs.isNotEmpty
	}

	func setup() async {
		await setInitialStatus()

		guard observerTask == nil else { return }
		observerTask = Task(priority: .background) {
			for await result in Transaction.updates {
				self.consumeVerificationResult(for: result)
			}
		}
	}

	private func setInitialStatus() async {
		for await result in Transaction.currentEntitlements {
			consumeVerificationResult(for: result)
		}
	}

	private func consumeVerificationResult(for result: VerificationResult<Transaction>) {
		guard case .verified(let transaction) = result else { return }

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

	deinit {
		observerTask?.cancel()
	}
}
