//
//  ProfileSettingsView.swift
//  YouHQ
//
//  Created by Ryan Token on 1/25/26.
//

import SwiftUI

struct ProfileSettingsView: View {
	@Environment(PaywallManager.self) private var paywallManager
	@Environment(PaywallPresenter.self) private var paywallPresenter
	@State private var vm = ViewModel()

	private let profileText = "Profiles hold residences, vehicles, money, media, and career info"

	var body: some View {
		let selectedProfileID = vm.selectedProfile?.profile.id

		List {
			Group {
				Section("Profiles") {
					ForEach(vm.profiles) { profile in
						ProfileRow(
							profile: profile,
							isSelected: profile.profile.id == selectedProfileID,
							vm: vm
						)
					}
				}

				Button(action: createProfile) {
					AddMoreButtonLabel(text: "Create Profile", backgroundColor: .indigo)
				}
				.buttonStyle(.plain)
				.listRowBackground(Color.clear)
				.alert("Create Profile", isPresented: $vm.isShowingCreateProfileAlert) {
					TextField("Profile Name", text: $vm.newProfileName)
						#if !os(macOS)
							.textInputAutocapitalization(.words)
						#endif
					Button {
						vm.createProfile(named: vm.newProfileName)
					} label: {
						HQText("Create")
					}
					Button(role: .cancel) {
						vm.newProfileName = ""
					}
				} message: {
					HQText("\(profileText).")
				}

				ProfileExplanation()
					.listRowBackground(Color.clear)
					.padding(.top)
			}
			.listRowSeparator(.hidden)
		}
		.contentMargins(.top, 0)
		.navigationTitle("Profiles")
		#if !os(macOS)
			.navigationBarTitleDisplayMode(.inline)
		#endif
		// Attached once to the list rather than to every row, so each confirmation has a
		// single presenter instead of one per profile all bound to the same state.
		.alert("Switch Profile", item: $vm.profileToConfirmSwitch) { profile in
			Button("Switch Profile") { vm.switchProfile(to: profile) }
			Button("Cancel", role: .cancel) { vm.profileToConfirmSwitch = nil }
		} message: { profile in
			HQText("Switch to \(profile.name)?")
		}
		.alert("Delete Profile", item: $vm.profileToConfirmDelete) { profile in
			Button("Delete", role: .destructive) { vm.deleteProfile(profile) }
			Button("Cancel", role: .cancel) { vm.profileToConfirmDelete = nil }
		} message: { profile in
			HQText("Delete \(profile.name) Profile?")
		}
		.alert("Cannot Delete Profile", isPresented: $vm.isShowingCannotDeleteLastProfile) {
		} message: {
			HQText("You must have at least one profile")
		}
		.alert("Rename Profile", item: $vm.profileToConfirmRename) { profile in
			TextField("Profile Name", text: $vm.renameProfileText)
			Button("Rename") { vm.renameProfile(profile, to: vm.renameProfileText) }
			Button("Cancel", role: .cancel) {
				vm.renameProfileText = ""
				vm.profileToConfirmRename = nil
			}
		}
		.task {
			await vm.onAppear()
		}
	}

	private func createProfile() {
		if paywallManager.hasUnlockedPremium {
			vm.isShowingCreateProfileAlert = true
		} else {
			paywallPresenter.showPaywallFromSettings()
		}
	}
}

#Preview {
	NavigationStack {
		ProfileSettingsView()
	}
	.environment(PaywallManager())
	.environment(PaywallPresenter())
}
