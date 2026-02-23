//
//  Paywall+ThankYouBadge.swift
//  YouHQ
//
//  Created by Ryan Token on 2/22/26.
//

import SwiftUI

extension Paywall {
	struct ThankYouBadge: View {
		var body: some View {
			HQText("🎉 Thank you for supporting YouHQ!")
				.padding(12)
				.padding(.horizontal, 8)
				.background(.white.opacity(0.9))
				.clipShape(.capsule)
				.padding(.vertical, 24)
				.font(.headline.weight(.semibold))
				.rainbowGradient()
		}
	}
}

#Preview {
	Paywall.ThankYouBadge()
}
