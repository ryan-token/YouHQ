//
//  TermsAndPrivacyPolicyButton.swift
//  YouHQ
//
//  Created by Ryan Token on 1/25/26.
//

import SwiftUI

struct TermsAndPrivacyPolicyButton: View {
    var body: some View {
		Menu {
			// TODO: Link to Terms/Privacy Policy links
			Button {
				print("Link to Terms of Use")
			} label: {
				Text("Terms of Use")
			}

			Button {
				print("Link to Privacy Policy")
			} label: {
				Text("Privacy Policy")
			}
		} label: {
			HStack {
				Label {
					Text("Terms & Privacy Policy")
				} icon: {
					Image(systemName: "lock.square.fill")
						.font(.title3)
						.foregroundStyle(.gray)
				}

				Spacer()
			}
			.contentShape(.rect)
		}
		.buttonStyle(.plain)
    }
}

#Preview {
    TermsAndPrivacyPolicyButton()
}
