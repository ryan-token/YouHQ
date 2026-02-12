//
//  Paywall+MarketingCopy.swift
//  YouHQ
//
//  Created by Ryan Token on 1/31/26.
//

import StoreKit
import SwiftUI

extension Paywall {
	struct MarketingCopy: View {
		@Environment(\.colorScheme) var colorScheme
		@Environment(PaywallManager.self) private var paywallManager

		let fromSettings: Bool
		let fromOnboarding: Bool
		let onComplete: (() -> Void)?

		var hstackSpacing: CGFloat {
			#if os(macOS)
				64
			#else
				if UIDevice.current.userInterfaceIdiom == .phone {
					10
				} else {
					32
				}
			#endif
		}

		init(fromSettings: Bool = false, fromOnboarding: Bool = false, onComplete: (() -> Void)? = nil) {
			self.fromSettings = fromSettings
			self.fromOnboarding = fromOnboarding
			self.onComplete = onComplete
		}

		var body: some View {
			VStack(spacing: 8) {
				VStack(spacing: 0) {
					ScalableImage("AppIcon", height: 90)

					VStack(spacing: 4) {
						HQText("YouHQ Premium")
							.font(.largeTitle)
							.fontWeight(.black)

						HQText("Made with ❤️ by an independent developer")
							.font(.headline)
					}
				}
				.padding(.top)
				#if !os(macOS)
					.if(UIDevice.current.userInterfaceIdiom == .pad) {
						$0.padding(.top, 40)
					}
				#endif

				HStack(alignment: .top, spacing: hstackSpacing) {
					VStack(alignment: .leading, spacing: 2) {
						HQText("Free:")
							.font(.headline.weight(.semibold))
						Group {
							HQText("• 1 Profile")
							HQText("• 1 Residence")
							HQText("• 1 Vehicle")
							HQText("• \(Constants.paywallCoreItemsThreshold) Items per Tab")
							HQText("• \(Constants.paywallPaintColorsThreshold) Paint Colors")
							HQText("• \(Constants.paywallPaintColorsThreshold) Maintenance Items")
							HQText("• Profiles Can't Be Shared")
						}
					}
					.foregroundStyle(.white.opacity(0.7))

					VStack(alignment: .leading, spacing: 2) {
						HQText("YouHQ Premium:")
							.foregroundStyle(
								LinearGradient(
									colors: [.pink, .orange, .yellow, .green, .blue, .purple], startPoint: .leading, endPoint: .trailing)
							)
							.font(.headline.weight(.semibold))
						Group {
							HQText("🎭 Unlimited Profiles")
							HQText("🏠 Unlimited Residences")
							HQText("🚗 Unlimited Vehicles")
							HQText("💯 Unlimited Items")
							HQText("✨ Unlimited Everything")
							HQText("☁️ Profile Sharing")
							HQText("🙏 My Undying Gratitude")
						}
					}
				}
				.font(.subheadline.weight(.medium))
				.multilineTextAlignment(.leading)
				.frame(maxWidth: .infinity, alignment: .center)

				Group {
					if fromOnboarding {
						Button {
							onComplete?()
						} label: {
							HQText("Skip")
								.foregroundStyle(.white.opacity(0.7))
								.fontWeight(.medium)
								.padding(.horizontal)
						}
						.buttonStyle(.bordered)
						.controlSize(.regular)
					} else {
						if paywallManager.hasUnlockedPremium {
							HQText("🎉 Thank you for supporting YouHQ!")
								.font(.headline.weight(.semibold))
								.animation(.default, value: paywallManager.hasUnlockedPremium)
						}
					}
				}
				.padding(.top, 8)
				.padding(.bottom, 2)

				Spacer()
			}
			.foregroundStyle(.white)
			#if os(visionOS)
				.background(PaywallGradient())
			#else
				.containerBackground(for: .subscriptionStoreFullHeight) {
					PaywallGradient()
				}
			#endif
		}
	}
}

#Preview {
	Paywall.MarketingCopy()
}
