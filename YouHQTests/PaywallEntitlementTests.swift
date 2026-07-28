//
//  PaywallEntitlementTests.swift
//  YouHQTests
//
//  Created by Ryan Token on 7/28/26.
//

import Foundation
import StoreKit
import StoreKitTest
import Testing

@testable import YouHQ

extension YouHQTests {
	/// Guards the two invariants behind the paywall bugs that reached customers: every
	/// transaction gets finished, and only a verified one unlocks anything.
	///
	/// These drive real StoreKit through `SKTestSession` rather than a stand-in, because both
	/// bugs were a misreading of what StoreKit does, which a fake would have reproduced
	/// faithfully. StoreKit state is process-wide, hence `.serialized` and a fresh session per
	/// test. The time limit is there so a stalled StoreKit sequence fails rather than hangs.
	///
	/// Note that `SKTestSession` on the simulator issues payloads that fail device
	/// verification, so its transactions arrive `.unverified`. That is what makes the second
	/// test possible and what puts entitlement-granting out of reach here; granting is covered
	/// by manual testing against sandbox instead.
	@Suite("Paywall entitlements", .serialized, .timeLimit(.minutes(1)))
	@MainActor
	struct PaywallEntitlementTests {
		/// The bug Apple rejected the app for, under guideline 2.1(b).
		///
		/// Nothing ever called `Transaction.finish()`, so transactions stayed queued. The App
		/// Store handed one back from the next purchase attempt, which looked like a purchase
		/// that succeeded instantly and unlocked nothing, and replayed it through
		/// `Transaction.updates` on launch, which unlocked the app for a reviewer who had
		/// never bought anything.
		@Test("Transactions left unfinished by an earlier version are drained on setup")
		func drainsUnfinishedTransactions() async throws {
			let session = try storeSession()
			_ = try await session.buyProduct(identifier: Self.monthlyID)
			try #require(await unfinishedCount() == 1, "the backlog this test exists to drain")

			await PaywallManager().setup()

			#expect(await unfinishedCount() == 0)
		}

		/// Draining the queue must never be mistaken for granting the purchase. Finishing a
		/// transaction the device cannot verify is what keeps the queue moving, so this pins
		/// down that doing so buys the customer nothing.
		@Test("A transaction that fails verification is finished but unlocks nothing")
		func unverifiedTransactionUnlocksNothing() async throws {
			let session = try storeSession()
			_ = try await session.buyProduct(identifier: Self.monthlyID)
			let purchase = try #require(await Transaction.latest(for: Self.monthlyID))
			guard case .unverified = purchase else {
				Issue.record("Expected the simulator's test session to produce an unverified payload")
				return
			}

			let manager = PaywallManager()

			#expect(await manager.record(purchase) == false)
			#expect(!manager.hasUnlockedPremium)
			#expect(await unfinishedCount() == 0)
		}

		// MARK: - Helpers

		private static let monthlyID = "com.ryantoken.YouHQ.premium.monthly"

		/// The app's own StoreKit configuration, so the tests buy the real product identifiers.
		private static let configurationURL = URL(filePath: #filePath)
			.deletingLastPathComponent()
			.deletingLastPathComponent()
			.appending(path: "YouHQ/StoreKit Configuration.storekit")

		private func storeSession() throws -> SKTestSession {
			let session = try SKTestSession(contentsOf: Self.configurationURL)
			session.resetToDefaultState()
			session.clearTransactions()
			session.disableDialogs = true
			return session
		}

		private func unfinishedCount() async -> Int {
			var count = 0
			for await _ in Transaction.unfinished { count += 1 }
			return count
		}
	}
}
