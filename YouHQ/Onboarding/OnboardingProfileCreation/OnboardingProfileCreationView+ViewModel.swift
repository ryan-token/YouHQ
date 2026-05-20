//
//  OnboardingProfileCreationView+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 2/15/26.
//

import SQLiteData
import SwiftUI

extension OnboardingProfileCreationView {
	@Observable
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) private var database

		@ObservationIgnored
		@Dependency(\.date.now) private var now

		@ObservationIgnored
		@AppStorage("selectedProfileID") var selectedProfileIDString: String = ""

		var showAddResidence = false
		var showAddVehicle = false
		var showAddJob = false
		var isShowingCreateProfileAlert = false
		var showPaywallSheet = false
		var hasAnyProfile = false
		var existingProfileName = ""
		var newProfileName = ""
		var createdNewProfile = false
		var createdProfileName = ""
		var residencesCount = 0
		var vehiclesCount = 0
		var jobsCount = 0

		var selectedProfileID: UUID? {
			UUID(uuidString: selectedProfileIDString)
		}

		var isProfileNameEmpty: Bool {
			newProfileName.trimmingCharacters(in: .whitespaces).isEmpty
		}

		func checkForProfile() async {
			do {
				let profiles = try await database.read { db in
					try Profile.fetchAll(db)
				}
				hasAnyProfile = profiles.isNotEmpty
				existingProfileName = profiles.first?.name ?? ""

				// Only load counts if we have a valid selectedProfileID
				if selectedProfileID != nil {
					await loadItemCounts()
				}
			} catch {
				print("Error checking for profiles: \(error.localizedDescription)")
				hasAnyProfile = false
				existingProfileName = ""
			}
		}

		func loadItemCounts() async {
			guard let selectedProfileID else {
				residencesCount = 0
				vehiclesCount = 0
				jobsCount = 0
				return
			}

			do {
				let counts = try await database.read { db in
					let residences =
						try Residence
						.where { $0.profileID.eq(selectedProfileID) }
						.fetchCount(db)
					let vehicles =
						try Vehicle
						.where { $0.profileID.eq(selectedProfileID) }
						.fetchCount(db)
					let jobs =
						try Job
						.where { $0.profileID.eq(selectedProfileID) }
						.fetchCount(db)
					return (residences, vehicles, jobs)
				}

				residencesCount = counts.0
				vehiclesCount = counts.1
				jobsCount = counts.2
			} catch {
				print("Error loading item counts: \(error.localizedDescription)")
				residencesCount = 0
				vehiclesCount = 0
				jobsCount = 0
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

				selectedProfileIDString = id.uuidString
				createdNewProfile = true
				createdProfileName = profileName
				notifyProfileChanged()
			} catch {
				Analytics.logError(id: .profileSaveFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}

		func checkIfJobWasSaved(jobID: UUID) async -> Bool {
			do {
				let savedJob = try await database.read { db in
					try Job.find(jobID).fetchOne(db)
				}
				return savedJob != nil
			} catch {
				Analytics.logError(id: .jobSaveVerificationFailed, message: error.localizedDescription)
				return false
			}
		}
	}
}
