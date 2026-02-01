//
//  RateAppButton.swift
//  YouHQ
//
//  Created by Ryan Token on 1/25/26.
//

import SwiftUI

struct RateAppButton: View {
	@State private var isShowingNotLiveAlert = false

	var body: some View {
		Button {
			// TODO: Link to rate in the App Store
			isShowingNotLiveAlert = true
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
		.alert(
			"App is Not Live",
			isPresented: $isShowingNotLiveAlert
		) {
			Button("OK", role: .close) {}
		} message: {
			HQText(
				"Once this app is live on the App Store, this button will take you there to rate & review it."
			)
		}
	}
}

#Preview {
	RateAppButton()
}
