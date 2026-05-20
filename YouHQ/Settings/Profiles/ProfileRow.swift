//
//  ProfileRow.swift
//  YouHQ
//
//  Created by Ryan Token on 1/27/26.
//

import SwiftUI

struct ProfileRow: View {
	let profile: ProfileShare
	@Bindable var vm: ProfileSettingsView.ViewModel

	var isSelected: Bool {
		vm.selectedProfile?.profile.id == profile.profile.id
	}

	var body: some View {
		Button {
			if !isSelected {
				vm.confirmProfileSwitch(for: profile.profile)
			}
		} label: {
			HStack {
				Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
					.rowIcon(color: isSelected ? .indigo : .gray)
					.animation(.default, value: isSelected)

				VStack(alignment: .leading) {
					HQText(profile.profile.name)
						.font(.headline)

					#if DEBUG
						HQText("\(profile.profile.id)")
							.font(.caption2)
					#endif
				}

				Spacer()

				SharingStatus(for: profile, shouldShowShareButtonIfNotShared: true, isInsideSheet: true)
					.layoutPriority(1)
			}
			.contentShape(.rect)
		}
		.buttonStyle(.plain)
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

		.alert(
			"Switch Profile",
			isPresented: $vm.profileToConfirmSwitch.isPresent(),
			presenting: vm.profileToConfirmSwitch
		) { profile in
			Button("Switch Profile") { vm.switchProfile(to: profile) }
			Button("Cancel", role: .cancel) { vm.profileToConfirmSwitch = nil }
		} message: { profile in
			HQText("Switch to \(profile.name)?")
		}

		.alert(
			"Delete Profile",
			isPresented: $vm.profileToConfirmDelete.isPresent(),
			presenting: vm.profileToConfirmDelete
		) { profile in
			Button("Delete", role: .destructive) { vm.deleteProfile(profile) }
			Button("Cancel", role: .cancel) { vm.profileToConfirmDelete = nil }
		} message: { profile in
			HQText("Delete \(profile.name) Profile?")
		}

		.alert(
			"Cannot Delete Profile",
			isPresented: $vm.isShowingCannotDeleteLastProfile
		) {
		} message: {
			HQText("You must have at least one profile")
		}

		.alert(
			"Rename Profile",
			isPresented: $vm.profileToConfirmRename.isPresent(),
			presenting: vm.profileToConfirmRename
		) { profile in
			TextField("Profile Name", text: $vm.renameProfileText)
			Button("Rename") { vm.renameProfile(profile, to: vm.renameProfileText) }
			Button("Cancel", role: .cancel) {
				vm.renameProfileText = ""
				vm.profileToConfirmRename = nil
			}
		} message: { _ in
			HQText("")
		}
	}
}

#Preview {
	ProfileRow(profile: ProfileShare(profile: Profile.sampleData, isShared: true, metadata: nil), vm: ProfileSettingsView.ViewModel())
}
