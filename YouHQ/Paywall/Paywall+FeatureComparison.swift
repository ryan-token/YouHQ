//
//  Paywall+FeatureComparison.swift
//  YouHQ
//
//  Created by Ryan Token on 2/22/26.
//

import SwiftUI

extension Paywall {
	struct FeatureComparison: View {
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

		var body: some View {
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
						.rainbowGradient()
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
		}
	}
}

#Preview {
	Paywall.FeatureComparison()
}
