//
//  Paywall.swift
//  YouHQ
//
//  Created by Ryan Token on 1/31/26.
//

import StoreKit
import SwiftUI

struct Paywall: View {
	@Environment(PaywallManager.self) private var paywallManager
	@State private var shouldRainConfetti = false
	@State private var refreshTrigger = UUID()

	let fromSettings: Bool
	let fromOnboarding: Bool
	let onComplete: (() -> Void)?
	let animationDuration: TimeInterval = 7

	init(fromSettings: Bool = false, fromOnboarding: Bool = false, onComplete: (() -> Void)? = nil) {
		self.fromSettings = fromSettings
		self.fromOnboarding = fromOnboarding
		self.onComplete = onComplete
	}

	var body: some View {
		ZStack {
			SubscriptionStoreView(groupID: paywallManager.subscriptionGroupID) {
				MarketingCopy(fromOnboarding: fromOnboarding, onComplete: onComplete)
			}
			.if(fromSettings) {
				$0.storeButton(.hidden, for: .cancellation)
			}
			.storeButton(.visible, for: .restorePurchases)
			.id(refreshTrigger)
			.onAppear {
				refreshTrigger = UUID() // SubscriptionStoreView loses the active plan without this
			}
			.onInAppPurchaseCompletion { _, result in
				handleIAPResult(result)
			}

			if shouldRainConfetti {
				ParticleEmitter(
					images: ["confetti"],
					particleCount: 350,
					creationPoint: .init(x: 0.5, y: -0.3),
					creationRange: CGSize(width: 1, height: 0),
					colors: [.red, .yellow, .blue, .green, .white, .orange, .purple],
					angle: .degrees(180),
					angleRange: .radians(.pi / 4),
					rotationRange: .radians(.pi * 2),
					rotationSpeed: .radians(.pi),
					scale: 0.6,
					speed: 2500,
					speedRange: 800,
					animation: Animation.linear(duration: animationDuration),
					animationDelayThreshold: 4
				)
			}
		}
	}

	private func handleIAPResult(_ result: Result<Product.PurchaseResult, any Error>) {
		switch result {
		case .success(.success(let transaction)):
			rainConfetti()
			logStoreKitTransaction(transaction)
			if fromOnboarding {
				onComplete?()
			}
		case .success(.pending):
			Analytics.sendSignal(.IAPSuccessPending)
		case .success(.userCancelled):
			Analytics.sendSignal(.IAPSuccessUserCancelled)
		case .success(_): // swiftlint:disable:this empty_enum_arguments
			Analytics.sendSignal(.IAPSuccessUnknown)
		case .failure(let error):
			Analytics.logError(id: .IAPFailed, message: error.localizedDescription)
		}
	}

	private func rainConfetti() {
		shouldRainConfetti = true

		Task {
			try? await Task.sleep(for: .seconds(animationDuration))
			shouldRainConfetti = false
		}
	}

	private func logStoreKitTransaction(_ transaction: VerificationResult<StoreKit.Transaction>) {
		do {
			let verifiedTransaction = try transaction.payloadValue
			Analytics.trackPurchase(for: verifiedTransaction)
		} catch {
			Analytics.logError(id: .IAPUnverified, message: error.localizedDescription)
		}
	}
}

#Preview {
	struct PaywallPreview: View {
		@State private var paywallManager = PaywallManager()

		var body: some View {
			Paywall()
				.environment(paywallManager)
		}
	}
	return PaywallPreview()
}
