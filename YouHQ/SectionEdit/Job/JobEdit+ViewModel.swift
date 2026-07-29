//
//  JobEdit+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

extension JobEdit {
	@Observable
	final class ViewModel: SectionEditViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		let job: Job
		let isNew: Bool

		var company: String
		var jobTitle: String
		var startDate: Date?
		var endDate: Date?
		var isCurrent: Bool
		var salary: Double?
		var currencyCode: String?
		var employmentType: EmploymentType
		var url: String
		var notes: String

		// Profile switching support
		@ObservationIgnored
		@FetchAll(ProfileShare.none, animation: .default) var profiles
		var currentProfileID: UUID
		var supportsProfileSwitching: Bool { true }
		var itemNameForProfilePicker: String {
			company.isNotEmpty ? company : "this job"
		}

		var title: String {
			isNew ? "Add Job" : "Edit Job"
		}

		var isValid: Bool {
			true
		}

		var deleteConfirmationMessage: String {
			"Are you sure you want to delete \(company.isNotEmpty ? company : "this job")?"
		}

		init(job: Job, isNew: Bool) {
			self.job = job
			self.isNew = isNew
			self.company = job.company
			self.jobTitle = job.title
			self.startDate = job.startDate
			self.endDate = job.endDate
			self.isCurrent = job.isCurrent
			self.salary = job.salary
			self.currencyCode = job.currencyCode
			self.employmentType = job.employmentType
			self.url = job.url
			self.notes = job.notes
			self.currentProfileID = job.profileID
		}

		func loadProfiles() async {
			await ProfileShare.reload(into: $profiles)
		}

		func save() {
			do {
				try database.write { db in
					if isNew {
						// Insert new record
						try Job.insert {
							Job.Draft(
								id: job.id,
								profileID: currentProfileID,
								company: company,
								title: jobTitle,
								startDate: startDate,
								endDate: endDate,
								isCurrent: isCurrent,
								salary: salary,
								currencyCode: currencyCode,
								employmentType: employmentType,
								backgroundColor: job.backgroundColor,
								url: url,
								notes: notes
							)
						}
						.execute(db)
						Analytics.sendSignal(.careerJobCreated)
					} else {
						// Update existing record
						try Job.find(job.id)
							.update {
								$0.profileID = currentProfileID
								$0.company = company
								$0.title = jobTitle
								$0.startDate = startDate
								$0.endDate = endDate
								$0.isCurrent = isCurrent
								$0.salary = salary
								$0.currencyCode = currencyCode
								$0.employmentType = employmentType
								$0.url = url
								$0.notes = notes
							}
							.execute(db)
					}
				}
			} catch {
				Analytics.logError(id: .jobSaveFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}

		func cancel() {
			// Draft items don't need cleanup since they're never in DB
		}

		func delete() {
			do {
				try database.write { db in
					try Job.find(job.id)
						.delete()
						.execute(db)
				}
				Analytics.sendSignal(.careerJobDeleted)
			} catch {
				Analytics.logError(id: .jobDeleteFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}
	}
}
