//
//  FreeTierLimitationCard.swift
//  YouHQ
//
//  Created by Ryan Token on 2/15/26.
//

import SwiftUI

struct FreeTierLimitationCard: View {
	let profileName: String

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack(spacing: 8) {
				Image(systemName: "person.circle.fill")
					.foregroundStyle(.indigo)
					.font(.largeTitle)

				VStack(alignment: .leading, spacing: 0) {
					HQText("You already have a profile")
						.font(.headline)
						.fontWeight(.semibold)

					HQText("Profile: \(profileName)")
						.foregroundStyle(.secondary)
						.font(.subheadline)
				}
			}

			Text(
				"""
				The free version of YouHQ allows \(Constants.paywallProfilesThreshold) profile. \
				To create additional profiles, subscribe to **YouHQ Premium**.
				"""
			)
			.foregroundStyle(.secondary)
			.font(.callout)
			.fontDesign(.rounded)
		}
		.padding(12)
		.background(.quinary, in: .rect(cornerRadius: 24))
	}
}

#Preview {
	FreeTierLimitationCard(profileName: "Profile 1")
}
