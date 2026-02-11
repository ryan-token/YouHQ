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
	@State private var vm = ViewModel()
	@Binding var createdNewProfile: Bool
	@Binding var createdProfileName: String

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
			}
			.contentMargins(.top, 0)
			.navigationTitle("Create Profile")
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

		var isProfileNameEmpty: Bool {
			newProfileName.trimmingCharacters(in: .whitespaces).isEmpty
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
}
