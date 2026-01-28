//
//  ProfileRow.swift
//  YouHQ
//
//  Created by Ryan Token on 1/27/26.
//

import SwiftUI

struct ProfileRow: View {
	let profile: ProfileShare
	let vm: ProfileSettingsView.ViewModel

    var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Text(profile.profile.name)
					.font(.headline)
				Text("ID: \(profile.profile.id)")
					.font(.caption)
			}

			Spacer()

			SharingStatus(for: profile, shouldShowShareButtonIfNotShared: true)
		}
		.swipeActions(edge: .trailing, allowsFullSwipe: false) {
			Button {
				vm.confirmProfileDelete(for: profile.profile)
			} label: {
				Image(systemName: "trash")
					.tint(.red)
			}
		}
		.alert(
			"Delete Profile",
			isPresented: .init(
				get: { vm.profileDeletionAlert != .empty },
				set: { if !$0 { vm.profileDeletionAlert = .empty } }
			)
		) {
			switch vm.profileDeletionAlert {
			case .empty:
				EmptyView()
			case .cannotDeleteDefault:
				Button("OK") {
					vm.profileDeletionAlert = .empty
				}
			case .confirmDelete(let profile):
				Button("Delete", role: .destructive) {
					vm.deleteProfile(profile)
				}
				Button("Cancel", role: .cancel) {
					vm.profileDeletionAlert = .empty
				}
			}
		} message: {
			switch vm.profileDeletionAlert {
			case .empty:
				Text("")
			case .cannotDeleteDefault:
				Text("You cannot delete the Default profile")
			case .confirmDelete(let profile):
				Text("Delete \(profile.name) Profile?")
			}
		}
    }
}

#Preview {
	ProfileRow(profile: ProfileShare(profile: Profile.sampleData, isShared: true), vm: ProfileSettingsView.ViewModel())
}
