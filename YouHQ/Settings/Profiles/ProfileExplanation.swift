//
//  ProfileExplanation.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import SwiftUI

/// Explains what profiles are, shared by Profile settings and onboarding's profile step.
struct ProfileExplanation: View {
	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("A **Profile** holds residences, vehicles, money, media, and career info.")

			Text(
				"""
				**Create additional profiles** to manage data for someone else, \
				or to isolate your own data more cleanly.
				"""
			)

			Text("You can **switch between profiles** at any time.")

			Text(
				"""
				Profiles can be **shared** with others. Sharing a profile \
				with someone else means all data in that profile \
				will be synced seamlessly between all participants.
				"""
			)
		}
		.fontDesign(.rounded)
		.foregroundStyle(.secondary)
	}
}

#Preview {
	ProfileExplanation()
		.padding()
}
