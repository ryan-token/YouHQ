//
//  CareerTests.swift
//  YouHQTests
//
//  Created by Ryan Token on 2/21/26.
//

import Dependencies
import DependenciesTestSupport
import Foundation
import SQLiteData
import Testing

@testable import YouHQ

extension YouHQTests {
	@Suite("Career")
	struct CareerTests {

		@Suite("Jobs")
		struct Jobs {
			@Dependency(\.defaultDatabase) var database

			@Test("Load fetches jobs for a profile")
			func loadJobs() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Job.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							company: "Acme Corp",
							title: "Engineer",
							salary: 100_000
						)
						Job.Draft(
							id: UUID(-3),
							profileID: UUID(-1),
							company: "BigCo",
							title: "Senior Engineer",
							salary: 130_000
						)
					}
				}

				let vm = JobViewModel()
				await vm.load(for: UUID(-1))

				#expect(vm.jobs.count == 2)
				let first = try #require(vm.jobs.first)
				#expect(first.company == "Acme Corp" || first.company == "BigCo")
			}

			@Test("Create draft has correct profile ID and defaults")
			func createDraft() {
				let vm = JobViewModel()
				let draft = vm.createDraft(for: UUID(-1))

				#expect(draft.profileID == UUID(-1))
				#expect(draft.company == "")
				#expect(draft.title == "")
				#expect(draft.salary == nil)
				#expect(draft.isCurrent == false)
			}

			@Test("Delete removes job from database")
			func deleteJob() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Job.Draft(id: UUID(-2), profileID: UUID(-1), company: "OldCo", title: "Intern")
					}
				}

				let vm = JobViewModel()
				await vm.load(for: UUID(-1))
				let first = try #require(vm.jobs.first)
				vm.delete(first)

				let remaining = try await database.read { db in try Job.fetchCount(db) }
				#expect(remaining == 0)
			}

		}

	}
}
