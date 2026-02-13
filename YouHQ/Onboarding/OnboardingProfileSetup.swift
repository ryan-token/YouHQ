//
//  OnboardingProfileSetup.swift
//  YouHQ
//
//  Created by Ryan Token on 2/10/26.
//

import SQLiteData
import SwiftUI

struct OnboardingProfileSetup: View {
	@Environment(\.dismiss) private var dismiss
	@Environment(PaywallManager.self) private var paywallManager
	@State private var vm = ViewModel()
	@Binding var createdNewProfile: Bool
	@Binding var createdProfileName: String

	private var isFreeTierLimited: Bool {
		vm.profileCount >= 1 && !paywallManager.hasUnlockedPremium
	}

	var body: some View {
		NavigationStack {
			List {
				Section {
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
							You can **switch between profiles** at any time from Settings.
							"""
						)

						Text(
							"""
							Profiles can be **shared** with others. Sharing a profile \
							with someone else means all data in that profile \
							will be synced seamlessly between all participants.
							"""
						)

						if isFreeTierLimited {
							Text(
								"""
								**Note:** The free version of YouHQ includes 1 profile. \
								You already have a profile, so you'll need to subscribe to YouHQ Premium \
								to create additional profiles.
								"""
							)
							.foregroundStyle(.secondary)
							.padding(.top, 8)
						}
					}
					.fontDesign(.rounded)
					.listRowBackground(Color.clear)
				}
				.listRowSeparator(.hidden)

				Button {
					vm.isShowingCreateProfileAlert = true
				} label: {
					AddMoreButtonLabel(text: "Create Profile", backgroundColor: .indigo)
				}
				.buttonStyle(.plain)
				.listRowBackground(Color.clear)
				.listRowSeparator(.hidden)
				.disabled(isFreeTierLimited)
				.opacity(isFreeTierLimited ? 0.5 : 1.0)
			}
			.contentMargins(.top, 0)
			.navigationTitle("Create Profile")
			#if os(macOS)
				.frame(minHeight: 500)
			#endif
			#if !os(macOS)
				.navigationBarTitleDisplayMode(.inline)
			#endif
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") {
						dismiss()
					}
				}
			}
			.task {
				await vm.checkProfileCount()
			}
			.alert("Create Profile", isPresented: $vm.isShowingCreateProfileAlert) {
				TextField("Profile Name", text: $vm.newProfileName)
					#if !os(macOS)
						.textInputAutocapitalization(.words)
					#endif
				Button {
					vm.createProfile(named: vm.newProfileName)
					createdNewProfile = true
					createdProfileName = vm.newProfileName
					dismiss()
				} label: {
					HQText("Create")
				}
				.disabled(vm.isProfileNameEmpty)
				Button(role: .cancel) {
					vm.newProfileName = ""
				}
			} message: {
				HQText("Profiles hold residences, vehicles, money, media, and career info.")
			}
		}
	}
}

extension OnboardingProfileSetup {
	@Observable
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) private var database

		@ObservationIgnored
		@Dependency(\.date.now) var now

		@ObservationIgnored
		@AppStorage("selectedProfileID") var selectedProfileIDString: String = ""

		var isShowingCreateProfileAlert = false
		var newProfileName = ""
		var profileCount = 0

		var isProfileNameEmpty: Bool {
			newProfileName.trimmingCharacters(in: .whitespaces).isEmpty
		}

		func checkProfileCount() async {
			do {
				let count = try await database.read { db in
					try Profile.fetchCount(db)
				}
				profileCount = count
			} catch {
				print("Error checking profile count: \(error)")
				profileCount = 0
			}
		}

		func createProfile(named profileName: String) {
			do {
				let id = UUID()
				try database.write { db in
					try Profile.insert {
						Profile.Draft(
							id: id,
							name: profileName,
							createdAt: now,
							updatedAt: now
						)
					}
					.execute(db)
					Analytics.sendSignal(.profileCreated)
				}

				// Automatically select the newly created profile
				selectedProfileIDString = id.uuidString
				notifyProfileChanged()
			} catch {
				Analytics.logError(id: .profileSaveFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}
	}
}

#Preview {
	OnboardingProfileSetup(
		createdNewProfile: .constant(false),
		createdProfileName: .constant("")
	)
	.environment(PaywallManager())
}
