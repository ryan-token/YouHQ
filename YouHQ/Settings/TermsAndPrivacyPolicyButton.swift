//
//  TermsAndPrivacyPolicyButton.swift
//  YouHQ
//
//  Created by Ryan Token on 1/25/26.
//

import SwiftUI

struct TermsAndPrivacyPolicyButton: View {
	@Environment(\.openURL) var openURL

	var body: some View {
		Menu {
			// TODO: Link to Terms/Privacy Policy links
			Button {
				openURL(Constants.termsOfUseURL)
			} label: {
				Text("Terms of Use")
			}

			Button {
				openURL(Constants.privacyPolicyURL)
			} label: {
				Text("Privacy Policy")
			}
		} label: {
			HStack {
				Label {
					Text("Terms & Privacy Policy")
				} icon: {
					Image(systemName: "lock.square.fill")
						.rowIcon(color: .gray)
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
	TermsAndPrivacyPolicyButton()
}
