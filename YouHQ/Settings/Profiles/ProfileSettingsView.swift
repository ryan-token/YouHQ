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
					ForEach(vm.profiles) { profile in
						ProfileRow(profile: profile, vm: vm)
					}
				}

				Button {
					if paywallManager.hasUnlockedPremium {
						vm.isShowingCreateProfileAlert = true
					} else {
						paywallManager.showPaywallFromSettings()
					}
				} label: {
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

				VStack(alignment: .leading, spacing: 12) {
					Text("A **Profile** holds residences, vehicles, money, media, and career info.")

					Text(
						"""
						**Create additional profiles** to manage data for someone else, \
						or to isolate your own data more cleanly.
						"""
					)

					Text(
						"""
						You can **switch between profiles** at any time.
						"""
					)

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
