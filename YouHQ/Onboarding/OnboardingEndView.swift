//
//  OnboardingEndView.swift
//  YouHQ
//
//  Created by Ryan Token on 2/7/26.
//

import SwiftUI

struct OnboardingEndView: View {
	var onContinue: () -> Void

	var body: some View {
		ScrollView {
			VStack(spacing: 24) {
				VStack(alignment: .leading, spacing: 12) {
					HQText("YouHQ is your personal command center for life's important details.")
					HQText(
						"Track everything from home maintenance and vehicles to career history and where all of your money is, all in one place."
					)
					HQText(
						"""
						🔒 Your data is your own. All of your data stays on your devices \
						and is synced securely over iCloud via your Apple Account.
						""")
				}
				.foregroundStyle(.secondary)
				.frame(maxWidth: .infinity, alignment: .leading)

				VStack(spacing: 16) {
					HQText("It all starts with a profile")
						.font(.title2)
						.fontWeight(.semibold)
						.frame(maxWidth: .infinity, alignment: .leading)

					Button {
						onContinue()
					} label: {
						HQText("Let's Go")
							.fontWeight(.semibold)
							.frame(maxWidth: .infinity)
					}
					.buttonStyle(.borderedProminent)
					.controlSize(.large)
				}

				Link(
					"Privacy Policy",
					destination: Constants.privacyPolicyURL
				)
				.foregroundStyle(.accent)
				.font(.callout)
				.fontWeight(.medium)
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding(.top, 16)

				Spacer()
			}
			.padding()
			.padding(.horizontal, 8)
		}
		.toolbar(removing: .title)
	}
}

#Preview {
	OnboardingEndView(onContinue: {})
}
