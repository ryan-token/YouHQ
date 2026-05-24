//
//  RateAppButton.swift
//  YouHQ
//
//  Created by Ryan Token on 1/25/26.
//

import SwiftUI

struct RateAppButton: View {
	@Environment(\.openURL) var openURL

	var body: some View {
		Button {
			openURL(Constants.appStoreURL)
		} label: {
			HStack {
				Label {
					HQText("Rate")
						.fontWeight(.medium)
				} icon: {
					Image(systemName: "heart.square.fill")
						.rowIcon(color: .pink)
				}

				Spacer()

				ExternalLinkIndicator()
			}
			.contentShape(.rect)
		}
		.buttonStyle(.plain)
	}
}

#Preview {
	RateAppButton()
}
