//
//  AvailableProfilesView.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct AvailableProfilesView: View {
	let profiles: [ResidenceScreen.ViewModel.ProfileShare]

	init(for profiles: [ResidenceScreen.ViewModel.ProfileShare]) {
		self.profiles = profiles
	}

    var body: some View {
		VStack {
			ForEach(profiles, id: \.profile.id) { profile in
				HStack(spacing: 2) {
					Text("Profile: \(profile.profile.name)")
					Text("-")
					Text("\(profile.profile.id)")
						.textSelection(.enabled)
				}
				.font(.caption)
			}
		}
    }
}

#Preview {
	AvailableProfilesView(for: [
		ResidenceScreen.ViewModel.ProfileShare.init(
			profile: Profile.sampleData,
			isShared: false
		)
	])
}
