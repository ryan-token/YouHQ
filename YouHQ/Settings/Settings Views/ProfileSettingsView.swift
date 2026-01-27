//
//  ProfileSettingsView.swift
//  YouHQ
//
//  Created by Ryan Token on 1/25/26.
//

import SwiftUI

struct ProfileSettingsView: View {
	@State private var vm = ViewModel()

	let profileText = "Profiles hold residences, vehicles, money, media, and career info"

	var body: some View {
		List {
			Group {
				Section("Profiles") {
					ForEach(vm.profiles, id: \.profile.id) { profile in
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
							Button(role: .destructive) {
								vm.confirmProfileDelete(for: profile.profile)
							} label: {
								Label("Delete", systemImage: "trash")
							}
						}
					}
					.alert("Delete Profile", isPresented: $vm.isShowingDeleteProfileAlert) {
						if !vm.isDeletingDefaultProfile {
							Button(role: .destructive) {
								vm.deleteProfile(vm.profileToDelete)
							} label: {
								Text("Delete")
							}

							Button(role: .cancel) {
								vm.profileToDelete = nil
							}
						} else {
							Button {
								vm.profileToDelete = nil
								vm.deleteProfileMessage = ""
							} label: {
								Text("OK")
							}
						}
					} message: {
						Text(vm.deleteProfileMessage)
					}
				}

				Button {
					vm.isShowingCreateProfileAlert = true
				} label: {
					AddMoreButtonLabel(text: "Create Profile")
				}
				.buttonStyle(.plain)
				.listRowBackground(Color.clear)

				.alert("Create Profile", isPresented: $vm.isShowingCreateProfileAlert) {
					TextField("Profile Name", text: $vm.newProfileName)
					Button {
						vm.createProfile(named: vm.newProfileName)
					} label: {
						Text("Create")
					}
					Button(role: .cancel) {
						vm.newProfileName = ""
					}
				} message: {
					Text("\(profileText).")
				}

				VStack(alignment: .leading, spacing: 12) {
					Text("\(profileText).")
					Text(
						"""
						Create additional profiles to manage data for someone else, \
						or just to separate your data cleanly.
						""")
					Text(
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
