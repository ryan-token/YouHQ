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

			@Test("Jobs scoped to profile")
			func jobsScopedToProfile() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Alice", createdAt: Date(), updatedAt: Date())
						Profile.Draft(id: UUID(-2), name: "Bob", createdAt: Date(), updatedAt: Date())
						Job.Draft(id: UUID(-3), profileID: UUID(-1), company: "Alice Corp")
						Job.Draft(id: UUID(-4), profileID: UUID(-2), company: "Bob LLC")
					}
				}

				let aliceJobs = try await database.read { db in
					try Job.where { $0.profileID.eq(UUID(-1)) }.fetchAll(db)
				}
				#expect(aliceJobs.count == 1)
				let aliceJob = try #require(aliceJobs.first)
				#expect(aliceJob.company == "Alice Corp")
			}
		}

		// MARK: - SalaryChart.ViewModel Tests

		@Suite("Salary chart")
		struct SalaryChartTests {
			@Test("Prepare chart data filters out jobs without salary")
			func filtersNullSalary() throws {
				let vm = SalaryChart.ViewModel()
				let jobs = [
					Job(id: UUID(-1), profileID: UUID(-2), company: "Acme", startDate: Date(timeIntervalSince1970: 100), salary: 80_000),
					Job(id: UUID(-3), profileID: UUID(-2), company: "NoSalary"),
					Job(id: UUID(-4), profileID: UUID(-2), company: "BigCo", startDate: Date(timeIntervalSince1970: 200), salary: 120_000),
				]

				let chartData = vm.prepareChartData(from: jobs)
				#expect(chartData.count == 2)
				let first = try #require(chartData.first)
				let last = try #require(chartData.last)
				#expect(first.salary == 80_000)
				#expect(last.salary == 120_000)
			}

			@Test("Chart data sorts by start date ascending")
			func sortsByStartDate() throws {
				let vm = SalaryChart.ViewModel()
				let jobs = [
					Job(
						id: UUID(-1), profileID: UUID(-2), company: "Later",
						startDate: Date(timeIntervalSince1970: 200), salary: 100_000
					),
					Job(
						id: UUID(-3), profileID: UUID(-2), company: "Earlier",
						startDate: Date(timeIntervalSince1970: 100), salary: 80_000
					),
				]

				let chartData = vm.prepareChartData(from: jobs)
				let first = try #require(chartData.first)
				let last = try #require(chartData.last)
				#expect(first.xLabel == "Earlier")
				#expect(last.xLabel == "Later")
			}

			@Test("Empty company name becomes Untitled")
			func emptyCompanyBecomesUntitled() throws {
				let vm = SalaryChart.ViewModel()
				let jobs = [
					Job(id: UUID(-1), profileID: UUID(-2), company: "", salary: 50_000)
				]

				let chartData = vm.prepareChartData(from: jobs)
				let first = try #require(chartData.first)
				#expect(first.xLabel == "Untitled")
			}

			@Test("Format compact salary handles various ranges")
			func formatCompactSalary() {
				let vm = SalaryChart.ViewModel()

				#expect(vm.formatCompactSalary(1_500_000) == "$1.5M")
				#expect(vm.formatCompactSalary(120_000) == "$120K")
				#expect(vm.formatCompactSalary(500) == "$500")
			}

			@Test("Chart label includes index")
			func chartLabel() {
				let vm = SalaryChart.ViewModel()
				let data = SalaryChart.JobChartData(
					id: UUID(-1),
					xLabel: "Acme",
					salary: 100_000,
					backgroundColor: "blue",
					index: 2
				)

				#expect(vm.chartLabel(for: data) == "Acme (3)")
			}

			@Test("Format X axis label strips index suffix")
			func formatXAxisLabel() {
				let vm = SalaryChart.ViewModel()

				#expect(vm.formatXAxisLabel("Acme (1)") == "Acme")
				#expect(vm.formatXAxisLabel("BigCo (12)") == "BigCo")
				#expect(vm.formatXAxisLabel("NoIndex") == "NoIndex")
			}

			@Test("Selected job updates from label via didSet")
			func selectedJobFromLabel() {
				let vm = SalaryChart.ViewModel()
				let jobs = [
					Job(id: UUID(-1), profileID: UUID(-2), company: "Acme", startDate: Date(timeIntervalSince1970: 100), salary: 80_000),
					Job(id: UUID(-3), profileID: UUID(-2), company: "BigCo", startDate: Date(timeIntervalSince1970: 200), salary: 120_000),
				]

				let _ = vm.prepareChartData(from: jobs)

				// Set label to match first job
				vm.selectedJobLabel = "Acme (1)"
				#expect(vm.selectedJob?.xLabel == "Acme")
				#expect(vm.selectedJob?.salary == 80_000)

				// Set to nil clears selection
				vm.selectedJobLabel = nil
				#expect(vm.selectedJob == nil)
			}
		}

		// MARK: - Sorted Jobs Tests

		@Suite("Job sorting")
		struct JobSorting {
			@Test("Current jobs come before past jobs")
			func currentJobsFirst() throws {
				let jobs = [
					Job(id: UUID(-1), profileID: UUID(-2), company: "Past", isCurrent: false),
					Job(id: UUID(-3), profileID: UUID(-2), company: "Current", isCurrent: true),
				]

				let current = jobs.filter { $0.isCurrent }
				let past = jobs.filter { !$0.isCurrent }
				let sorted = current + past

				let first = try #require(sorted.first)
				let last = try #require(sorted.last)
				#expect(first.company == "Current")
				#expect(last.company == "Past")
			}
		}

		// MARK: - Career Cascade Deletion

		@Suite("Cascade deletion")
		struct CascadeDeletion {
			@Dependency(\.defaultDatabase) var database

			@Test("Deleting a profile cascades to jobs")
			func cascadeFromProfile() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Job.Draft(id: UUID(-2), profileID: UUID(-1), company: "Acme", salary: 80_000)
						Job.Draft(id: UUID(-3), profileID: UUID(-1), company: "BigCo", salary: 120_000)
					}
				}

				try await database.write { db in
					try Profile.find(UUID(-1)).delete().execute(db)
				}

				let count = try await database.read { db in try Job.fetchCount(db) }
				#expect(count == 0)
			}
		}
	}
}
