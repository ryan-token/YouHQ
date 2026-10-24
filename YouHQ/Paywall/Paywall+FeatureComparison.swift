//
//  Paywall+FeatureComparison.swift
//  YouHQ
//
//  Created by Ryan Token on 2/22/26.
//

import SwiftUI

extension Paywall {
	struct FeatureComparison: View {
		@Environment(\.dynamicTypeSize) private var dynamicTypeSize
		#if !os(macOS)
			@Environment(\.horizontalSizeClass) private var horizontalSizeClass
		#endif

		private var columnSpacing: Double {
			#if os(macOS)
				64
			#else
				horizontalSizeClass == .regular ? 32 : 10
			#endif
		}

		/// Side-by-side columns, stacked once accessibility text sizes leave too little width
		/// for two. `AnyLayout` keeps the columns' identity when the arrangement changes.
		private var layout: AnyLayout {
			if dynamicTypeSize.isAccessibilitySize {
				AnyLayout(VStackLayout(alignment: .leading))
			} else {
				AnyLayout(HStackLayout(alignment: .top, spacing: columnSpacing))
			}
		}

		var body: some View {
			layout {
				VStack(alignment: .leading, spacing: 2) {
					HQText("Free:")
						.font(.headline.weight(.semibold))
					HQText("• 1 Profile")
					HQText("• 1 Residence")
					HQText("• 1 Vehicle")
					HQText("• \(Constants.paywallCoreItemsThreshold) Items per Tab")
					HQText("• \(Constants.paywallPaintColorsThreshold) Paint Colors")
					HQText("• \(Constants.paywallPaintColorsThreshold) Maintenance Items")
					HQText("• Profiles Can't Be Shared")
				}
				.foregroundStyle(.white.opacity(0.7))

				VStack(alignment: .leading, spacing: 2) {
					HQText("YouHQ Premium:")
						.rainbowGradient()
						.font(.headline.weight(.semibold))
					HQText("🎭 Unlimited Profiles")
					HQText("🏠 Unlimited Residences")
					HQText("🚗 Unlimited Vehicles")
					HQText("💯 Unlimited Items")
					HQText("✨ Unlimited Everything")
					HQText("☁️ Profile Sharing")
					HQText("🙏 My Undying Gratitude")
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
