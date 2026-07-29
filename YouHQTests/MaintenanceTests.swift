//
//  MaintenanceTests.swift
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
	@Suite("Maintenance")
	struct MaintenanceTests {

		@Suite("Due date logic")
		struct DueDateLogic {
			@Test("isPastDue returns true when due date is in the past")
			func pastDue() {
				let item = MaintenanceItem(
					id: UUID(-1), profileID: nil,
					residenceID: UUID(-2),
					vehicleID: nil,
					name: "Filter change",
					dueDate: Date(timeIntervalSinceNow: -86400) // yesterday
				)
				#expect(item.isPastDue)
			}

			@Test("isPastDue returns false when due date is in the future")
			func notPastDue() {
				let item = MaintenanceItem(
					id: UUID(-1), profileID: nil,
					residenceID: UUID(-2),
					vehicleID: nil,
					name: "Filter change",
					dueDate: Date(timeIntervalSinceNow: 86400 * 60) // 60 days from now
				)
				#expect(!item.isPastDue)
			}

			@Test("isPastDue returns false when no due date")
			func noDueDate() {
				let item = MaintenanceItem(
					id: UUID(-1), profileID: nil,
					residenceID: UUID(-2),
					vehicleID: nil,
					name: "Filter change",
					dueDate: nil
				)
				#expect(!item.isPastDue)
			}

			@Test("isUpcoming returns true when due within 30 days")
			func upcomingWithin30Days() {
				let item = MaintenanceItem(
					id: UUID(-1), profileID: nil,
					residenceID: UUID(-2),
					vehicleID: nil,
					name: "Filter change",
					dueDate: Date(timeIntervalSinceNow: 86400 * 15) // 15 days from now
				)
				#expect(item.isUpcoming)
			}

			@Test("isUpcoming returns false when more than 30 days out")
			func notUpcoming() {
				let item = MaintenanceItem(
					id: UUID(-1), profileID: nil,
					residenceID: UUID(-2),
					vehicleID: nil,
					name: "Filter change",
					dueDate: Date(timeIntervalSinceNow: 86400 * 60) // 60 days from now
				)
				#expect(!item.isUpcoming)
			}

			@Test("isUpcoming returns false for past due items")
			func pastDueNotUpcoming() {
				let item = MaintenanceItem(
					id: UUID(-1), profileID: nil,
					residenceID: UUID(-2),
					vehicleID: nil,
					name: "Filter change",
					dueDate: Date(timeIntervalSinceNow: -86400) // yesterday
				)
				#expect(!item.isUpcoming)
			}

			@Test("calculateNextDueDate adds correct interval")
			func calculateNextDueDate() {
				let calendar = Calendar.current
				let now = Date()

				// Monthly interval
				let monthlyItem = MaintenanceItem(
					id: UUID(-1), profileID: nil,
					residenceID: UUID(-2),
					vehicleID: nil,
					name: "Monthly task",
					intervalType: .month,
					intervalValue: 3
				)
				let nextMonthly = monthlyItem.calculateNextDueDate(from: now)
				let expectedMonthly = calendar.date(byAdding: .month, value: 3, to: now)!
				#expect(calendar.isDate(nextMonthly, inSameDayAs: expectedMonthly))

				// Yearly interval
				let yearlyItem = MaintenanceItem(
					id: UUID(-3), profileID: nil,
					residenceID: UUID(-2),
					vehicleID: nil,
					name: "Annual task",
					intervalType: .year,
					intervalValue: 1
				)
				let nextYearly = yearlyItem.calculateNextDueDate(from: now)
				let expectedYearly = calendar.date(byAdding: .year, value: 1, to: now)!
				#expect(calendar.isDate(nextYearly, inSameDayAs: expectedYearly))
			}
		}

		// MARK: - MaintenanceItemViewModel Tests

		@Suite("View model")
		struct ViewModel {
			@Dependency(\.defaultDatabase) var database

			@Test("Load fetches items for a residence")
			func loadForResidence() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						MaintenanceItem.Draft(id: UUID(-3), profileID: nil, residenceID: UUID(-2), vehicleID: nil, name: "HVAC filter")
						MaintenanceItem.Draft(id: UUID(-4), profileID: nil, residenceID: UUID(-2), vehicleID: nil, name: "Gutter clean")
					}
				}

				let vm = MaintenanceItemViewModel()
				await vm.load(for: UUID(-2))

				#expect(vm.maintenanceItems.count == 2)
			}

			@Test("Load fetches items for a vehicle")
			func loadForVehicle() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Vehicle.Draft(id: UUID(-2), profileID: UUID(-1), make: "Toyota")
						MaintenanceItem.Draft(id: UUID(-3), profileID: nil, residenceID: nil, vehicleID: UUID(-2), name: "Oil change")
					}
				}

				let vm = MaintenanceItemViewModel()
				await vm.loadVehicle(for: UUID(-2))

				#expect(vm.maintenanceItems.count == 1)
			}

			@Test("Create draft for residence sets correct IDs")
			func createResidenceDraft() {
				let vm = MaintenanceItemViewModel()
				let draft = vm.createDraft(for: UUID(-1))

				#expect(draft.residenceID == UUID(-1))
				#expect(draft.vehicleID == nil)
				#expect(draft.intervalType == .month)
				#expect(draft.intervalValue == 1)
			}

			@Test("Create draft for vehicle sets correct IDs")
			func createVehicleDraft() {
				let vm = MaintenanceItemViewModel()
				let draft = vm.createVehicleDraft(for: UUID(-1))

				#expect(draft.vehicleID == UUID(-1))
				#expect(draft.residenceID == nil)
			}
		}

		// MARK: - MaintenanceItemsScreen.ViewModel Tests

		@Suite("Screen view model")
		struct ScreenViewModel {
			@Dependency(\.defaultDatabase) var database

			@Test("Delete removes maintenance item from database")
			func deleteItem() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						MaintenanceItem.Draft(id: UUID(-3), profileID: nil, residenceID: UUID(-2), vehicleID: nil, name: "Filter")
					}
				}

				let vm = MaintenanceItemsScreen.ViewModel(residenceID: UUID(-2), vehicleID: nil)
				await vm.loadData()

				let item = try #require(vm.maintenanceItems.first)
				vm.deleteMaintenanceItem(item)

				let count = try await database.read { db in try MaintenanceItem.fetchCount(db) }
				#expect(count == 0)
			}

			@Test("Complete maintenance item creates completion record and updates due date")
			func completeItem() async throws {
				let dueDate = Date(timeIntervalSinceNow: -86400) // past due
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						MaintenanceItem.Draft(
							id: UUID(-3), profileID: nil,
							residenceID: UUID(-2),
							vehicleID: nil,
							name: "HVAC filter",
							intervalType: .month,
							intervalValue: 3,
							dueDate: dueDate
						)
					}
				}

				let vm = MaintenanceItemsScreen.ViewModel(residenceID: UUID(-2), vehicleID: nil)
				await vm.loadData()

				let item = try #require(vm.maintenanceItems.first)
				vm.completeMaintenanceItem(item)

				// Verify completion record was created
				let completionCount = try await database.read { db in
					try MaintenanceCompletion.fetchCount(db)
				}
				#expect(completionCount == 1)

				// Verify due date was updated (should be ~3 months from now)
				let updatedItem = try await database.read { db in
					try MaintenanceItem.find(UUID(-3)).fetchOne(db)
				}
				let updated = try #require(updatedItem)
				#expect(updated.lastCompletedAt != nil)
				#expect(updated.dueDate != nil)
				// New due date should be after the old due date
				#expect(updated.dueDate! > dueDate)
			}

			@Test("showAddMaintenanceItemSheet creates draft and shows sheet")
			func showAddSheet() {
				let vm = MaintenanceItemsScreen.ViewModel(residenceID: UUID(-1), vehicleID: nil)
				vm.showAddMaintenanceItemSheet()

				#expect(vm.draftMaintenanceItem != nil)
				#expect(vm.draftMaintenanceItem?.residenceID == UUID(-1))
				#expect(vm.draftMaintenanceItem?.vehicleID == nil)
				#expect(vm.isNewItem == true)
				#expect(vm.isShowingEditSheet == true)
			}

			@Test("editMaintenanceItem sets draft to existing item")
			func editItem() {
				let vm = MaintenanceItemsScreen.ViewModel(residenceID: UUID(-1), vehicleID: nil)
				let item = MaintenanceItem(
					id: UUID(-2), profileID: nil,
					residenceID: UUID(-1),
					vehicleID: nil,
					name: "Test item"
				)
				vm.editMaintenanceItem(item)

				#expect(vm.draftMaintenanceItem?.id == UUID(-2))
				#expect(vm.isNewItem == false)
				#expect(vm.isShowingEditSheet == true)
			}
		}

		// MARK: - Maintenance Cascade Deletion

		@Suite("Cascade deletion")
		struct CascadeDeletion {
			@Dependency(\.defaultDatabase) var database

			@Test("Deleting a maintenance item cascades to completions")
			func cascadeToCompletions() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						MaintenanceItem.Draft(id: UUID(-3), profileID: nil, residenceID: UUID(-2), vehicleID: nil, name: "Filter")
						MaintenanceCompletion.Draft(id: UUID(-4), maintenanceItemID: UUID(-3), completedAt: Date())
						MaintenanceCompletion.Draft(id: UUID(-5), maintenanceItemID: UUID(-3), completedAt: Date())
					}
				}

				try await database.write { db in
					try MaintenanceItem.find(UUID(-3)).delete().execute(db)
				}

				let count = try await database.read { db in try MaintenanceCompletion.fetchCount(db) }
				#expect(count == 0)
			}
		}
	}
}
