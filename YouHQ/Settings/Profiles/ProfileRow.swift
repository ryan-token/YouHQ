//
//  ProfileRow.swift
//  YouHQ
//
//  Created by Ryan Token on 1/27/26.
//

import SwiftUI

struct ProfileRow: View {
	let profile: ProfileShare
	let isSelected: Bool
	let vm: ProfileSettingsView.ViewModel

	var body: some View {
		Button(action: requestSwitch) {
			HStack {
				Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
					.rowIcon(color: isSelected ? .indigo : .gray)
					.animation(.default, value: isSelected)

				VStack(alignment: .leading) {
					HQText(profile.profile.name)
						.font(.headline)

					#if DEBUG
						HQText("\(profile.profile.id)")
							.font(.caption)
							.foregroundStyle(.secondary)
					#endif
				}

				Spacer()

				SharingStatus(for: profile, shouldShowShareButtonIfNotShared: true, isInsideSheet: true)
					.layoutPriority(1)
			}
			.contentShape(.rect)
		}
		.buttonStyle(.plain)
		.accessibilityAddTraits(isSelected ? .isSelected : [])
		.swipeActions(edge: .trailing, allowsFullSwipe: false) {
			Button("Delete", systemImage: "trash", role: .destructive) {
				vm.confirmProfileDelete(for: profile.profile)
			}
			.tint(.red)

			Button("Rename", systemImage: "pencil") {
				vm.confirmProfileRename(for: profile.profile)
			}
			.tint(.orange)
		}
	}

	private func requestSwitch() {
		if !isSelected {
			vm.confirmProfileSwitch(for: profile.profile)
		}
	}
}

#Preview {
	ProfileRow(
		profile: ProfileShare(profile: Profile.sampleData, isShared: true, metadata: nil),
		isSelected: true,
		vm: ProfileSettingsView.ViewModel()
	)
}
