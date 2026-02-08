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
		var body: some View {
			VStack(spacing: 12) {
				ScalableImage("AppIcon")

				VStack(spacing: 4) {
					HQText("YouHQ Premium")
						.foregroundStyle(.white)
						.font(.title)
						.bold()

					HQText("Made with ❤️ by an independent developer")
						.font(.headline)
				}

				VStack(alignment: .leading, spacing: 2) {
					HQText("With YouHQ Premium, you unlock:")
					Group {
						HQText("✨ Unlimited everything")
						HQText("☁️ Profile sharing over iCloud")
						HQText("🙏 My undying gratitude")
					}
					.padding(.leading, 12)
				}
				.font(.subheadline.weight(.medium))
				.multilineTextAlignment(.leading)
				.frame(maxWidth: .infinity, alignment: .center)
			}
			.padding(.vertical)
			.foregroundStyle(.white.opacity(0.7))
			#if os(visionOS)
				.background(LinearGradient(colors: [.indigo, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
			#else
				.containerBackground(for: .subscriptionStoreFullHeight) {
					LinearGradient(colors: [.indigo, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
				}
			#endif
		}
	}
}

#Preview {
	Paywall.MarketingCopy()
}
