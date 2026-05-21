//
//  ProfileSettingsView+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/26/26.
//

import SQLiteData
import Sharing
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
		@Shared(.appStorage(.selectedProfileIDKey)) var selectedProfileIDString = ""

		func setSelectedProfileIDString(_ value: String) {
			$selectedProfileIDString.withLock { $0 = value }
		}

		var selectedProfile: ProfileShare? {
			guard let selectedID = currentProfileID else { return nil }
			return profiles.first(where: { $0.profile.id == selectedID })
		}

		var hasMultipleProfiles: Bool {
			profiles.count > 1
		}

		var profileToConfirmSwitch: Profile?

		var isShowingCreateProfileAlert = false
		var newProfileName = ""

		var profileToConfirmDelete: Profile?
		var isShowingCannotDeleteLastProfile = false

		var renameProfileText = ""
		var profileToConfirmRename: Profile?

		func onAppear() async {
			await loadProfiles()
		}

		private func loadProfiles() async {
			await ProfileShare.reload(into: $profiles)
		}

		func confirmProfileSwitch(for profile: Profile) {
			profileToConfirmSwitch = profile
		}

		func switchProfile(to profile: Profile) {
			setCurrentProfileID(profile.id)
			profileToConfirmSwitch = nil
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
			if !hasMultipleProfiles {
				isShowingCannotDeleteLastProfile = true
				return
			}
			profileToConfirmDelete = profile
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
					// Switch to first available profile
					if let firstProfile = profiles.first(where: { $0.profile.id != profile.id }) {
						setCurrentProfileID(firstProfile.profile.id)
					} else {
						setCurrentProfileID(nil)
					}
					notifyProfileChanged()
				}

				Analytics.sendSignal(.profileDeleted)
			} catch {
				Analytics.logError(id: .profileDeleteFailed, message: error.localizedDescription)
				reportIssue(error)
			}

			profileToConfirmDelete = nil
		}

		func confirmProfileRename(for profile: Profile) {
			renameProfileText = profile.name
			profileToConfirmRename = profile
		}

		func renameProfile(_ profile: Profile, to newName: String) {
			do {
				try database.write { db in
					try Profile.find(profile.id)
						.update {
							$0.name = newName
							$0.updatedAt = now
						}
						.execute(db)
				}
			} catch {
				Analytics.logError(id: .profileRenameFailed, message: error.localizedDescription)
			}

			renameProfileText = ""
			profileToConfirmRename = nil
		}
	}
}
