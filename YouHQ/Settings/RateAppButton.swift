//
//  RateAppButton.swift
//  YouHQ
//
//  Created by Ryan Token on 1/25/26.
//

import SwiftUI

struct RateAppButton: View {
	var body: some View {
		Button {
			// TODO: Link to rate in the App Store
			print("Link to rate in the App Store")
		} label: {
			HStack {
				Label {
					Text("Rate")
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
