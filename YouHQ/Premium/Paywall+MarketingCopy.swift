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
			VStack(spacing: 16) {
				Image(systemName: "dollarsign.square.fill")
					.resizable()
					.scaledToFit()
					.frame(height: 60)
					.foregroundStyle(.white)

				VStack(spacing: 4) {
					Text("YouHQ Premium")
						.foregroundStyle(.white)
						.font(.title)
						.bold()

					Text("Made with ❤️ by an independent developer")
						.font(.headline)
				}

				VStack(alignment: .leading, spacing: 2) {
					Text("With YouHQ Premium, you unlock:")
					Group {
						Text("✨ Unlimited everything")
						Text("☁️ Profile sharing over iCloud")
						Text("🙏 My undying gratitude")
					}
					.padding(.leading, 8)
				}
				.font(.subheadline.weight(.medium))
				.multilineTextAlignment(.leading)
				.frame(maxWidth: .infinity, alignment: .center)
			}
			.padding(.vertical)
			.foregroundStyle(.white.opacity(0.6))
			.containerBackground(for: .subscriptionStoreFullHeight) {
				LinearGradient(colors: [.blue, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
			}
		}
	}
}

#Preview {
	Paywall.MarketingCopy()
}
