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
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) private var database

		@ObservationIgnored
		@Dependency(\.date.now) var now

		@ObservationIgnored
		@FetchAll(ProfileShare.none, animation: .default) var profiles

		var selectedProfile: ProfileShare?
		var profileToDelete: Profile?

		var isShowingCreateProfileAlert = false
		var newProfileName = ""

		var isShowingDeleteProfileAlert = false
		var isDeletingDefaultProfile = false
		var deleteProfileMessage = ""

		func onAppear() async {
			await loadProfiles()
			setProfile(to: "Default")
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
								isShared: $1.isShared.ifnull(false)
							)
						},
					animation: .default
				)
			}
		}

		private func setProfile(to profileName: String) {
			selectedProfile = profiles.first(where: {
				$0.profile.name == profileName
			})
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
				isDeletingDefaultProfile = true
				deleteProfileMessage = "You cannot delete the Default profile"
			} else {
				profileToDelete = profile
				deleteProfileMessage = "Delete \(profile.name) Profile?"
			}
			isShowingDeleteProfileAlert = true
		}

		func deleteProfile(_ profile: Profile?) {
			if let profile {
				do {
					try database.write { db in
						try Profile.find(profile.id)
							.delete()
							.execute(db)
					}

					Analytics.sendSignal(.profileDeleted)
				} catch {
					Analytics.logError(id: .profileDeleteFailed, message: error.localizedDescription)
					reportIssue(error)
				}

				deleteProfileMessage = ""
				profileToDelete = nil
			}
		}
	}
}
