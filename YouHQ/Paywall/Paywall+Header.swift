//
//  PaywallHeader.swift
//  YouHQ
//
//  Created by Ryan Token on 2/22/26.
//

import SwiftUI

extension Paywall {
	struct Header: View {
		@Environment(\.dismiss) private var dismiss
		let shouldShowDismissButton: Bool

		var body: some View {
			VStack(spacing: 0) {
				ZStack(alignment: .topTrailing) {
					ScalableImage("AppIcon-1024", height: 90)
						.frame(maxWidth: .infinity, alignment: .center)

					if shouldShowDismissButton {
						Button {
							dismiss()
						} label: {
							Label("Close", systemImage: "xmark")
								.labelStyle(.iconOnly)
								.font(.title2.weight(.medium))
								.frame(width: 20, height: 30)
								.contentShape(.circle)
						}
						#if os(visionOS)
							.buttonStyle(.bordered)
							.buttonBorderShape(.circle)
							.padding(.trailing)
						#else
							.buttonStyle(.glass)
						#endif
						.padding(4)
					}
				}

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
				// The paywall extends under the top edge so its gradient reaches it; this keeps
				// the header clear of the status bar and sheet grabber.
				.padding(.top, 40)
			#endif
		}
	}
}

#Preview {
	Paywall.Header(shouldShowDismissButton: true)
}
