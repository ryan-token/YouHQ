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
			Button {
				openURL(Constants.termsOfUseURL)
			} label: {
				HQText("Terms of Use")
			}

			Button {
				openURL(Constants.privacyPolicyURL)
			} label: {
				HQText("Privacy Policy")
			}
		} label: {
			HStack {
				Label {
					HQText("Terms & Privacy Policy")
						.fontWeight(.medium)
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
