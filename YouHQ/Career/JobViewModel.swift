//
//  JobViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

@Observable
class JobViewModel {
	@ObservationIgnored
	@Dependency(\.defaultDatabase) private var database

	@ObservationIgnored
	@FetchAll(Job.none, animation: .default) var jobs

	var draftJob: Job?

	func load(for profileID: UUID) async {
		_ = await withErrorReporting {
			try await $jobs.load(
				Job
					.where { $0.profileID.eq(profileID) }
					.order { $0.startDate.desc(nulls: .last) },
				animation: .default
			)
		}
	}

	func createDraft(for profileID: UUID) -> Job {
		Job(
			id: UUID(),
			profileID: profileID
		)
	}

	func delete(_ job: Job) {
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

	func updateBackgroundColor(_ color: Color, for job: Job) {
		withErrorReporting {
			try database.write { db in
				try Job.find(job.id)
					.update { $0.backgroundColor = color.databaseValue }
					.execute(db)
			}

			Analytics.sendSignal(.itemBackgroundColorChanged)
		}
	}
}
