//
//  AvailableProfilesView.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct AvailableProfilesView<T>: View where T: ProfileShareProtocol {
	let profiles: [T]

	init(for profiles: [T]) {
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
