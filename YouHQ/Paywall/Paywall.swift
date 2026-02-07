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
	let animationDuration: TimeInterval = 7

	init(fromSettings: Bool = false) {
		self.fromSettings = fromSettings
	}

	var body: some View {
		ZStack {
			SubscriptionStoreView(groupID: paywallManager.subscriptionGroupID) {
				MarketingCopy()
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
				if case .success(.success(let transaction)) = result {
					print("Purchased successfully: \(transaction.signedDate)")
					shouldRainConfetti = true

					Task {
						try? await Task.sleep(for: .seconds(animationDuration))
						shouldRainConfetti = false
					}
				} else {
					print("Something went wrong")
				}
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
