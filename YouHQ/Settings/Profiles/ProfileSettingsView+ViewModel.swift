//
//  ProfileSettingsView+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/26/26.
//

import SQLiteData
import SwiftUI

extension ProfileSettingsView {
	@Observable
	class ViewModel: ProfileSelection {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) private var database

		@ObservationIgnored
		@Dependency(\.date.now) var now

		@ObservationIgnored
		@FetchAll(ProfileShare.none, animation: .default) var profiles

		@ObservationIgnored
		@AppStorage("selectedProfileID") var selectedProfileIDString: String = ""

		var selectedProfile: ProfileShare? {
			guard let selectedID = currentProfileID else { return nil }
			return profiles.first(where: { $0.profile.id == selectedID })
		}

		var profileSwitchAlert: ProfileSwitchAlert = .empty

		enum ProfileSwitchAlert: Equatable { // swiftlint:disable:this nesting
			case empty
			case confirmSwitch(Profile)
		}

		var isShowingCreateProfileAlert = false
		var newProfileName = ""

		// Replace all the delete-related booleans with a single enum state
		var profileDeletionAlert: ProfileDeletionAlert = .empty

		// Add the enum definition
		enum ProfileDeletionAlert: Equatable { // swiftlint:disable:this nesting
			case empty
			case cannotDeleteDefault
			case confirmDelete(Profile)
		}

		func onAppear() async {
			await loadProfiles()
		}

		private func loadProfiles() async {
			_ = await withErrorReporting {
				try await $profiles.load(
					Profile
						.group(by: \.id)
						.leftJoin(SyncMetadata.all) {
							$0.syncMetadataID.eq($1.id)
						}
						.select {
							ProfileShare.Columns(
								profile: $0,
								isShared: $1.isShared.ifnull(false),
								metadata: $1
							)
						},
					animation: .default
				)
			}
		}

		func confirmProfileSwitch(for profile: Profile) {
			profileSwitchAlert = .confirmSwitch(profile)
		}

		func switchProfile(to profile: Profile) {
			currentProfileID = profile.id
			profileSwitchAlert = .empty
			notifyProfileChanged()
			Analytics.sendSignal(.profileSwitched)
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
			} catch {
				Analytics.logError(id: .profileSaveFailed, message: error.localizedDescription)
				reportIssue(error)
			}

			newProfileName = ""
		}

		func confirmProfileDelete(for profile: Profile) {
			if profile.name == "Default" {
				profileDeletionAlert = .cannotDeleteDefault
			} else {
				profileDeletionAlert = .confirmDelete(profile)
			}
		}

		func deleteProfile(_ profile: Profile) {
			do {
				try database.write { db in
					try Profile.find(profile.id)
						.delete()
						.execute(db)
				}

				// Handle profile deletion - switch to another profile if needed
				if currentProfileID == profile.id {
					// Switch to Default if available
					if let defaultProfile = profiles.first(where: { $0.profile.name == "Default" && $0.profile.id != profile.id }) {
						currentProfileID = defaultProfile.profile.id
					} else if let firstProfile = profiles.first(where: { $0.profile.id != profile.id }) {
						// Otherwise switch to first available
						currentProfileID = firstProfile.profile.id
					} else {
						currentProfileID = nil
					}
					notifyProfileChanged()
				}

				Analytics.sendSignal(.profileDeleted)
			} catch {
				Analytics.logError(id: .profileDeleteFailed, message: error.localizedDescription)
				reportIssue(error)
			}

			profileDeletionAlert = .empty
		}
	}
}
