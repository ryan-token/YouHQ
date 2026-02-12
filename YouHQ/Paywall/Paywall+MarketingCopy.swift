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
		let fromOnboarding: Bool
		let onComplete: (() -> Void)?

		var hstackSpacing: CGFloat {
			#if os(macOS)
				64
			#else
				4
			#endif
		}

		init(fromOnboarding: Bool = false, onComplete: (() -> Void)? = nil) {
			self.fromOnboarding = fromOnboarding
			self.onComplete = onComplete
		}

		var body: some View {
			VStack(spacing: 8) {
				VStack(spacing: 0) {
					ScalableImage("AppIcon", height: 90)

					VStack(spacing: 4) {
						HQText("YouHQ Premium")
							.foregroundStyle(.white)
							.font(.largeTitle)
							.fontWeight(.black)

						HQText("Made with ❤️ by an independent developer")
							.font(.headline)
					}
				}

				HStack(alignment: .top, spacing: hstackSpacing) {
					VStack(alignment: .leading, spacing: 2) {
						HQText("Free:")
							.foregroundStyle(.white)
							.font(.headline.weight(.semibold))
						Group {
							HQText("• 1 Profile")
							HQText("• 1 Residence")
							HQText("• 1 Vehicle")
							HQText("• \(Constants.paywallCoreItemsThreshold) Items per tab")
							HQText("• \(Constants.paywallPaintColorsThreshold) Paint Colors")
							HQText("• \(Constants.paywallPaintColorsThreshold) Maintenance Items")
							HQText("• Profiles can't be shared")
						}
					}

					VStack(alignment: .leading, spacing: 2) {
						HQText("YouHQ Premium:")
							.foregroundStyle(
								LinearGradient(
									colors: [.red, .orange, .yellow, .green, .blue, .purple], startPoint: .leading, endPoint: .trailing)
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

				if fromOnboarding {
					Button {
						onComplete?()
					} label: {
						HQText("Skip")
							.foregroundStyle(.indigo)
							.fontWeight(.medium)
							.frame(maxWidth: .infinity)
					}
					.padding(.top, 4)
					.buttonStyle(.plain)
					.controlSize(.regular)
				}
			}
			.padding(.vertical)
			.foregroundStyle(.white.opacity(0.7))
			#if os(visionOS)
				.background(LinearGradient(colors: [.indigo, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
			#else
				.containerBackground(for: .subscriptionStoreFullHeight) {
					LinearGradient(colors: [.black, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
				}
			#endif
		}
	}
}

#Preview {
	Paywall.MarketingCopy()
}
