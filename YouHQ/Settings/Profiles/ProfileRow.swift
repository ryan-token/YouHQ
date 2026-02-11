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

				SharingStatus(for: profile, shouldShowShareButtonIfNotShared: true)
					.layoutPriority(1)
			}
			.contentShape(.rect)
		}
		.buttonStyle(.plain)
		.swipeActions(edge: .trailing, allowsFullSwipe: false) {
			Button {
				vm.confirmProfileDelete(for: profile.profile)
			} label: {
				Image(systemName: "trash")
					.tint(.red)
			}

			Button {
				vm.confirmProfileRename(for: profile.profile)
			} label: {
				Image(systemName: "pencil")
					.tint(.orange)
			}
		}

		.alert(
			"Switch Profile",
			isPresented: .init(
				get: { vm.profileSwitchAlert != .empty },
				set: { if !$0 { vm.profileSwitchAlert = .empty } }
			)
		) {
			switch vm.profileSwitchAlert {
			case .empty:
				EmptyView()
			case .confirmSwitch(let profile):
				Button("Switch Profile") {
					vm.switchProfile(to: profile)
				}
				Button("Cancel", role: .cancel) {
					vm.profileSwitchAlert = .empty
				}
			}
		} message: {
			switch vm.profileSwitchAlert {
			case .empty:
				HQText("")
			case .confirmSwitch(let profile):
				HQText("Switch to \(profile.name)?")
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
			case .cannotDeleteLastProfile:
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
				HQText("")
			case .cannotDeleteLastProfile:
				HQText("You must have at least one profile")
			case .confirmDelete(let profile):
				HQText("Delete \(profile.name) Profile?")
			}
		}

		.alert(
			"Rename Profile",
			isPresented: .init(
				get: { vm.profileRenameAlert != .empty },
				set: { if !$0 { vm.profileRenameAlert = .empty } }
			)
		) {
			switch vm.profileRenameAlert {
			case .empty:
				EmptyView()
			case .confirmRename(let profile):
				TextField("Profile Name", text: $vm.renameProfileText)
				Button("Rename") {
					vm.renameProfile(profile, to: vm.renameProfileText)
				}
				Button("Cancel", role: .cancel) {
					vm.renameProfileText = ""
					vm.profileRenameAlert = .empty
				}
			}
		} message: {
			switch vm.profileRenameAlert {
			case .empty:
				HQText("")
			case .confirmRename:
				HQText("")
			}
		}
	}
}

#Preview {
	ProfileRow(profile: ProfileShare(profile: Profile.sampleData, isShared: true, metadata: nil), vm: ProfileSettingsView.ViewModel())
}
