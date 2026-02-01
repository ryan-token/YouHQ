//
//  ProfileSettingsView.swift
//  YouHQ
//
//  Created by Ryan Token on 1/25/26.
//

import SwiftUI

struct ProfileSettingsView: View {
	@Environment(PaywallManager.self) private var paywallManager
	@State private var vm = ViewModel()

	let profileText = "Profiles hold residences, vehicles, money, media, and career info"

	var body: some View {
		List {
			Group {
				Section("Profiles") {
					ForEach(vm.profiles, id: \.profile.id) { profile in
						ProfileRow(profile: profile, vm: vm)
					}
				}

				Button {
					if paywallManager.hasUnlockedPremium {
						vm.isShowingCreateProfileAlert = true
					} else {
						paywallManager.isShowingPaywallSheet = true
					}
				} label: {
					AddMoreButtonLabel(text: "Create Profile", backgroundColor: .indigo)
				}
				.buttonStyle(.plain)
				.listRowBackground(Color.clear)
				.alert("Create Profile", isPresented: $vm.isShowingCreateProfileAlert) {
					TextField("Profile Name", text: $vm.newProfileName)
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

				VStack(alignment: .leading, spacing: 12) {
					HQText("\(profileText).")
					HQText(
						"""
						Create additional profiles to manage data for someone else, \
						or just to separate your data cleanly.
						""")
					HQText(
						"""
						Profiles can be shared with others. Sharing a profile \
						with someone else means all data in that profile \
						will be synced seamlessly between you.
						""")
				}
				.foregroundStyle(.secondary)
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

		.task {
			await vm.onAppear()
		}
	}
}

#Preview {
	ProfileSettingsView()
}
