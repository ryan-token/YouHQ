//
//  CareerScreen+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

extension CareerScreen {
	@Observable
	class ViewModel: ProfileSelection {
		@ObservationIgnored
		@FetchAll(ProfileShare.none, animation: .default) var profiles

		@ObservationIgnored
		@AppStorage(.selectedProfileIDKey) var selectedProfileIDString: String = ""

		// Child view models for entity-specific operations
		var jobViewModel = JobViewModel()
		var otherViewModel = OtherItemViewModel()

		init() {}

		var selectedProfile: ProfileShare? {
			getSelectedProfile()
		}

		var careerItemsCount: Int {
			let jobsCount = jobViewModel.jobs.count
			let otherCount = otherViewModel.others.count
			return jobsCount + otherCount
		}

		var isShowingAddJobSheet = false
		var isShowingSectionEditSheet = false
		var sectionToEdit: EditableSection?
		var sheetTransitionSourceID: String = "addButton"

		var sortedJobs: [Job] {
			let currentJob = jobViewModel.jobs.filter { $0.isCurrent }
			let pastJobs = jobViewModel.jobs.filter { !$0.isCurrent }
				.sorted { job1, job2 in
					// Sort by end date descending (most recent first)
					// If no end date, sort by start date descending
					// If neither has dates, sort alphabetically by company
					if let endDate1 = job1.endDate, let endDate2 = job2.endDate {
						return endDate1 > endDate2
					} else if job1.endDate != nil {
						return true // Jobs with end dates come before those without
					} else if job2.endDate != nil {
						return false
					} else if let startDate1 = job1.startDate, let startDate2 = job2.startDate {
						return startDate1 > startDate2
					} else {
						return job1.company.localizedStandardCompare(job2.company) == .orderedAscending
					}
				}

			return currentJob + pastJobs
		}

		// MARK: PROFILE FUNCTIONS

		func loadProfiles() async {
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

		// MARK: CAREER DATA FUNCTIONS

		func loadCareerData() async {
			guard let profileID = selectedProfile?.profile.id else { return }
			await jobViewModel.load(for: profileID)
			await otherViewModel.loadCategory(for: .career, profileID: profileID)
		}

		// MARK: SHEET PRESENTATION

		func showAddJobSheet(sourceID: String = "addButton") {
			guard let profileID = selectedProfile?.profile.id else { return }
			jobViewModel.draftJob = jobViewModel.createDraft(for: profileID)
			sectionToEdit = .jobDraft
			sheetTransitionSourceID = sourceID
			isShowingSectionEditSheet = true
		}

		func showAddOtherSheet(sourceID: String = "addButton") {
			guard let profileID = selectedProfile?.profile.id else { return }
			otherViewModel.draftOther = otherViewModel.createCategoryDraft(
				for: .career,
				profileID: profileID
			)
			sectionToEdit = .otherDraft
			sheetTransitionSourceID = sourceID
			isShowingSectionEditSheet = true
		}
	}
}
