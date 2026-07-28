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

	@State private var showContent = false
	@State private var shouldRainConfetti = false

	let fromOnboarding: Bool
	let shouldShowSkipButton: Bool
	let shouldShowDismissButton: Bool
	let onComplete: (() -> Void)?
	let animationDuration: TimeInterval = 7

	init(
		fromOnboarding: Bool = false,
		shouldShowSkipButton: Bool = false,
		shouldShowDismissButton: Bool = true,
		onComplete: (() -> Void)? = nil
	) {
		self.fromOnboarding = fromOnboarding
		self.shouldShowSkipButton = shouldShowSkipButton
		self.shouldShowDismissButton = shouldShowDismissButton
		self.onComplete = onComplete
	}

	var body: some View {
		ZStack {
			SubscriptionStoreView(groupID: paywallManager.subscriptionGroupID) {
				MarketingCopy(
					shouldShowSkipButton: shouldShowSkipButton,
					shouldShowDismissButton: shouldShowDismissButton,
					onComplete: onComplete
				)
			}
			.opacity(showContent ? 1 : 0)
			.storeButton(.hidden, for: .cancellation)
			.storeButton(.visible, for: .restorePurchases)
			.onInAppPurchaseCompletion { _, result in
				await handleIAPResult(result)
			}
			.subscriptionStatusTask(for: paywallManager.subscriptionGroupID) { _ in
				// Catches what never arrives as a purchase result: restores, renewals, lapses,
				// and purchases made on the customer's other devices.
				await paywallManager.refreshEntitlements()
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
		.ignoresSafeArea(.all, edges: .vertical)
		.task {
			try? await Task.sleep(for: .seconds(0.5))
			withAnimation {
				showContent = true
			}
		}
		.onDisappear {
			showContent = false
		}
	}

	private func handleIAPResult(_ result: Result<Product.PurchaseResult, any Error>) async {
		switch result {
		case .success(.success(let verificationResult)):
			if case .unverified(_, let error) = verificationResult {
				Analytics.logError(id: .IAPUnverified, message: error.localizedDescription)
			}

			// Only celebrate once the entitlement has actually landed, since a purchase
			// succeeding and the app unlocking came apart badly enough to be worth checking.
			if await paywallManager.record(verificationResult) {
				rainConfetti()
			}

			// Advance either way. The customer has been charged by this point, so stranding
			// them on the paywall step helps nobody.
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
}

#Preview {
	struct PaywallPreview: View {
		@State private var paywallManager = PaywallManager()

		var body: some View {
			NavigationStack {
				Paywall()
					.environment(paywallManager)
			}
		}
	}
	return PaywallPreview()
}
