//
//  OnboardingProfileSetup+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 2/15/26.
//

import SQLiteData
import SwiftUI

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
