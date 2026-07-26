//
//  NotificationTests.swift
//  YouHQTests
//
//  Created by Ryan Token on 3/11/26.
//

import Dependencies
import DependenciesTestSupport
import Foundation
import SQLiteData
import Testing
import UserNotifications

@testable import YouHQ

// MARK: - Mock Notification Center

/// Records all interactions with the notification center for test assertions.
final class MockNotificationCenter: NotificationCenterProtocol, @unchecked Sendable {
	// Configuration
	var authorizationStatusValue: UNAuthorizationStatus = .authorized
	var requestAuthorizationResult: Bool = true
	var existingPendingRequests: [UNNotificationRequest] = []

	// Recorded calls
	private(set) var addedRequests: [UNNotificationRequest] = []
	private(set) var removedIdentifiers: [[String]] = []
	private(set) var requestAuthorizationCallCount = 0

	func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
		requestAuthorizationCallCount += 1
		return requestAuthorizationResult
	}

	func authorizationStatus() async -> UNAuthorizationStatus {
		authorizationStatusValue
	}

	func add(_ request: UNNotificationRequest) async throws {
		addedRequests.append(request)
	}

	func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
		removedIdentifiers.append(identifiers)
		existingPendingRequests.removeAll { identifiers.contains($0.identifier) }
	}

	func pendingNotificationRequests() async -> [UNNotificationRequest] {
		existingPendingRequests
	}
}

// MARK: - Tests

extension YouHQTests {
	@Suite("Notifications")
	struct NotificationTests {

		// MARK: - ReminderInterval

		@Suite("ReminderInterval")
		struct ReminderIntervalTests {
			@Test("displayName returns 'Never' for .none, rawValue otherwise")
			func displayName() {
				#expect(ReminderInterval.none.displayName == "Never")
				#expect(ReminderInterval.daily.displayName == "Daily")
				#expect(ReminderInterval.weekly.displayName == "Weekly")
				#expect(ReminderInterval.monthly.displayName == "Monthly")
				#expect(ReminderInterval.quarterly.displayName == "Quarterly")
				#expect(ReminderInterval.annually.displayName == "Annually")
			}
		}

		// MARK: - AppSettings Persistence

		@Suite("AppSettings persistence")
		struct AppSettingsPersistence {
			@Dependency(\.defaultDatabase) var database

			@Test("Migration seeds a default AppSettings row with .none interval")
			func defaultSeed() async throws {
				let settings = try await database.read { db in
					try AppSettings.fetchAll(db).first
				}
				let row = try #require(settings)
				#expect(row.reminderInterval == .none)
			}

			@Test("Updating reminderInterval persists across reads")
			func updateInterval() async throws {
				let settings = try await database.read { db in
					try AppSettings.fetchAll(db).first
				}
				let row = try #require(settings)

				let newInterval = ReminderInterval.weekly
				try await database.write { db in
					try AppSettings.find(row.id)
						.update { $0.reminderInterval = newInterval }
						.execute(db)
				}

				let updated = try await database.read { db in
					try AppSettings.find(row.id).fetchOne(db)
				}
				let updatedRow = try #require(updated)
				#expect(updatedRow.reminderInterval == .weekly)
			}

			@Test("Only one AppSettings row exists after migration")
			func singleRow() async throws {
				let count = try await database.read { db in
					try AppSettings.fetchCount(db)
				}
				#expect(count == 1)
			}
		}

		// MARK: - Onboarding Reminder ViewModel

		@Suite("OnboardingReminderView.ViewModel")
		struct OnboardingReminderVM {
			@Dependency(\.defaultDatabase) var database

			@Test("Initial selectedInterval defaults to .monthly")
			func initialInterval() {
				let vm = OnboardingReminderView.ViewModel()
				#expect(vm.selectedInterval == .monthly)
			}

			@Test("loadData picks up existing non-none interval from database")
			func loadDataExistingInterval() async throws {
				let settings = try await database.read { db in
					try AppSettings.fetchAll(db).first
				}
				let row = try #require(settings)

				let newInterval = ReminderInterval.quarterly
				try await database.write { db in
					try AppSettings.find(row.id)
						.update { $0.reminderInterval = newInterval }
						.execute(db)
				}

				let vm = OnboardingReminderView.ViewModel()
				await MainActor.run { vm.loadData() }

				await MainActor.run {
					#expect(vm.selectedInterval == .quarterly)
				}
			}

			@Test("loadData keeps default .monthly when database has .none")
			func loadDataNoneInterval() async {
				let vm = OnboardingReminderView.ViewModel()
				await MainActor.run { vm.loadData() }

				await MainActor.run {
					#expect(vm.selectedInterval == .monthly)
				}
			}

			@Test(
				"enableButtonText reflects selected interval",
				arguments: [
					(ReminderInterval.daily, "Enable Daily Reminder"),
					(.weekly, "Enable Weekly Reminder"),
					(.monthly, "Enable Monthly Reminder"),
					(.quarterly, "Enable Quarterly Reminder"),
					(.annually, "Enable Annual Reminder")
				]
			)
			func enableButtonText(interval: ReminderInterval, expected: String) async {
				let vm = OnboardingReminderView.ViewModel()
				await MainActor.run { vm.selectedInterval = interval }

				await MainActor.run {
					#expect(vm.enableButtonText == expected)
				}
			}
		}

		// MARK: - NotificationSettingsView ViewModel

		@Suite("NotificationSettingsView.ViewModel")
		struct SettingsVM {
			@Dependency(\.defaultDatabase) var database

			@Test("Initial state has correct defaults")
			func initialState() {
				let vm = NotificationSettingsView.ViewModel()
				#expect(vm.selectedInterval == .none)
				#expect(vm.isAuthorized == false)
				#expect(vm.isShowingPermissionAlert == false)
			}

			@Test("permissionStatusText reflects authorization state")
			func permissionStatusText() {
				let vm = NotificationSettingsView.ViewModel()

				#expect(vm.permissionStatusText == "Disabled")

				vm.isAuthorized = true
				#expect(vm.permissionStatusText == "Enabled")
			}

			@Test("revertInterval restores previousInterval")
			func revertInterval() async throws {
				let vm = NotificationSettingsView.ViewModel()

				// Load data to populate previousInterval from database (which is .none)
				await vm.loadData()

				await MainActor.run {
					// Simulate user changing interval
					vm.selectedInterval = .daily
					// Revert should restore to previous
					vm.revertInterval()
					#expect(vm.selectedInterval == .none)
				}
			}
		}

		// MARK: - NotificationManager Scheduling

		@Suite("NotificationManager scheduling")
		struct Scheduling {
			@Dependency(\.defaultDatabase) var database

			private func makeManager(
				status: UNAuthorizationStatus = .authorized,
				pendingRequests: [UNNotificationRequest] = []
			) -> (NotificationManager, MockNotificationCenter) {
				let mock = MockNotificationCenter()
				mock.authorizationStatusValue = status
				mock.existingPendingRequests = pendingRequests
				let manager = NotificationManager(center: mock)
				return (manager, mock)
			}

			// MARK: Update reminder scheduling

			@Test(
				"scheduleReminderNotification sets correct trigger for each interval",
				arguments: [
					ReminderInterval.daily,
					.weekly,
					.monthly,
					.quarterly,
					.annually
				]
			)
			func reminderTrigger(interval: ReminderInterval) async throws {
				let (manager, mock) = makeManager()
				try await manager.scheduleReminderNotification(interval: interval)

				let request = try #require(mock.addedRequests.last)
				#expect(request.identifier == NotificationManager.reminderNotificationIdentifier)

				let trigger = try #require(request.trigger as? UNCalendarNotificationTrigger)
				let dc = trigger.dateComponents

				#expect(dc.hour == 8)
				#expect(dc.minute == 0)

				switch interval {
				case .daily:
					#expect(trigger.repeats == true)
					#expect(dc.weekday == nil)
					#expect(dc.day == nil)
					#expect(dc.month == nil)
				case .weekly:
					#expect(trigger.repeats == true)
					#expect(dc.weekday == 2)
				case .monthly:
					#expect(trigger.repeats == true)
					#expect(dc.day == 1)
				case .quarterly:
					#expect(trigger.repeats == false)
					let month = try #require(dc.month)
					#expect([1, 4, 7, 10].contains(month))
					#expect(dc.day == 1)
				case .annually:
					#expect(trigger.repeats == true)
					#expect(dc.month == 1)
					#expect(dc.day == 1)
				default:
					Issue.record("Unexpected interval: \(interval.rawValue)")
				}
			}

			@Test("scheduleReminderNotification with .none cancels instead of scheduling")
			func reminderNoneCancels() async throws {
				let (manager, mock) = makeManager()
				try await manager.scheduleReminderNotification(interval: .none)

				#expect(mock.addedRequests.isEmpty)
				#expect(mock.removedIdentifiers == [[NotificationManager.reminderNotificationIdentifier]])
			}

			@Test("scheduleReminderNotification removes existing before adding new")
			func reminderRemovesExisting() async throws {
				let (manager, mock) = makeManager()
				try await manager.scheduleReminderNotification(interval: .weekly)

				#expect(mock.removedIdentifiers.count == 1)
				#expect(mock.removedIdentifiers[0] == [NotificationManager.reminderNotificationIdentifier])
				#expect(mock.addedRequests.count == 1)
			}

			@Test("scheduleReminderNotification does nothing when not authorized")
			func reminderNotAuthorized() async throws {
				let (manager, mock) = makeManager(status: .denied)
				try await manager.scheduleReminderNotification(interval: .daily)

				#expect(mock.addedRequests.isEmpty)
				#expect(mock.removedIdentifiers.isEmpty)
			}

			@Test("Reminder notification content has correct title and body")
			func reminderContent() async throws {
				let (manager, mock) = makeManager()
				try await manager.scheduleReminderNotification(interval: .daily)

				let request = try #require(mock.addedRequests.last)
				#expect(request.content.title == "Time to Update YouHQ Info")
				#expect(request.content.body == "Keep your info up to date so it's there when you need it.")
			}

			// MARK: Cancel reminder

			@Test("cancelReminderNotification removes correct identifier")
			func cancelReminder() {
				let (manager, mock) = makeManager()
				manager.cancelReminderNotification()

				#expect(mock.removedIdentifiers == [[NotificationManager.reminderNotificationIdentifier]])
			}

			// MARK: Maintenance item scheduling

			@Test("scheduleNotification schedules with correct content and 7 AM trigger")
			func scheduleMaintenanceItem() async throws {
				let dueDate = Date(timeIntervalSince1970: 2_000_000)
				let item = MaintenanceItem(
					id: UUID(-1),
					residenceID: UUID(-2),
					vehicleID: nil,
					name: "Change HVAC filter",
					dueDate: dueDate,
					shouldNotify: true,
					notificationIdentifier: "hvac-notif"
				)

				let (manager, mock) = makeManager()
				let result = try await manager.scheduleNotification(for: item)

				#expect(result == true)

				let request = try #require(mock.addedRequests.last)
				#expect(request.identifier == "hvac-notif")
				#expect(request.content.title == "Maintenance Due")
				#expect(request.content.body == "Change HVAC filter")

				let trigger = try #require(request.trigger as? UNCalendarNotificationTrigger)
				#expect(trigger.repeats == false)
				#expect(trigger.dateComponents.hour == 7)
				#expect(trigger.dateComponents.minute == 0)
			}

			@Test("scheduleNotification with shouldNotify=false cancels instead")
			func scheduleNotifyFalse() async throws {
				let item = MaintenanceItem(
					id: UUID(-1),
					residenceID: UUID(-2),
					vehicleID: nil,
					name: "Filter",
					dueDate: Date(timeIntervalSince1970: 2_000_000),
					shouldNotify: false,
					notificationIdentifier: "filter-notif"
				)
				let (manager, mock) = makeManager()
				let result = try await manager.scheduleNotification(for: item)

				#expect(result == true)
				#expect(mock.addedRequests.isEmpty)
				#expect(mock.removedIdentifiers == [["filter-notif"]])
			}

			@Test("scheduleNotification with no due date cancels instead")
			func scheduleNoDueDate() async throws {
				let item = MaintenanceItem(
					id: UUID(-1),
					residenceID: UUID(-2),
					vehicleID: nil,
					name: "Filter",
					shouldNotify: true,
					notificationIdentifier: "filter-notif"
				)
				let (manager, mock) = makeManager()
				let result = try await manager.scheduleNotification(for: item)

				#expect(result == true)
				#expect(mock.addedRequests.isEmpty)
				#expect(mock.removedIdentifiers == [["filter-notif"]])
			}

			@Test("scheduleNotification with empty identifier falls back to item ID and updates DB")
			func scheduleEmptyIdentifier() async throws {
				let itemID = UUID(-10)
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-11), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-12), profileID: UUID(-11), street: "123 Main")
						MaintenanceItem.Draft(
							id: itemID,
							residenceID: UUID(-12),
							vehicleID: nil,
							name: "Test Item",
							dueDate: Date(timeIntervalSince1970: 2_000_000),
							shouldNotify: true,
							notificationIdentifier: ""
						)
					}
				}

				let item = MaintenanceItem(
					id: itemID,
					residenceID: UUID(-12),
					vehicleID: nil,
					name: "Test Item",
					dueDate: Date(timeIntervalSince1970: 2_000_000),
					shouldNotify: true,
					notificationIdentifier: ""
				)

				let (manager, mock) = makeManager()
				let result = try await manager.scheduleNotification(for: item)

				#expect(result == true)

				let request = try #require(mock.addedRequests.last)
				#expect(request.identifier == itemID.uuidString)

				// Verify DB was updated with the fallback identifier
				let updated = try await database.read { db in
					try MaintenanceItem.find(itemID).fetchOne(db)
				}
				let updatedItem = try #require(updated)
				#expect(updatedItem.notificationIdentifier == itemID.uuidString)
			}

			@Test("scheduleNotification returns false when not authorized")
			func scheduleNotAuthorized() async throws {
				let item = MaintenanceItem(
					id: UUID(-1),
					residenceID: UUID(-2),
					vehicleID: nil,
					name: "Filter",
					dueDate: Date(timeIntervalSince1970: 2_000_000),
					shouldNotify: true,
					notificationIdentifier: "id"
				)
				let (manager, mock) = makeManager(status: .denied)
				let result = try await manager.scheduleNotification(for: item)

				#expect(result == false)
				#expect(mock.addedRequests.isEmpty)
			}

			// MARK: Cancel maintenance item notification

			@Test("cancelNotification uses notificationIdentifier when present")
			func cancelWithIdentifier() async {
				let item = MaintenanceItem(
					id: UUID(-1),
					residenceID: UUID(-2),
					vehicleID: nil,
					name: "Filter",
					notificationIdentifier: "custom-id"
				)
				let (manager, mock) = makeManager()
				await manager.cancelNotification(for: item)

				#expect(mock.removedIdentifiers == [["custom-id"]])
			}

			@Test("cancelNotification falls back to item ID when identifier is empty")
			func cancelWithFallback() async {
				let item = MaintenanceItem(
					id: UUID(-1),
					residenceID: UUID(-2),
					vehicleID: nil,
					name: "Filter",
					notificationIdentifier: ""
				)
				let (manager, mock) = makeManager()
				await manager.cancelNotification(for: item)

				#expect(mock.removedIdentifiers == [[UUID(-1).uuidString]])
			}

			// MARK: Refresh all notifications

			@Test("refreshAllNotifications removes stale, re-schedules items, and refreshes reminder")
			func refreshAll() async throws {
				let dueDate = Date(timeIntervalSince1970: 2_000_000)
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-20), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-21), profileID: UUID(-20), street: "123 Main")
						MaintenanceItem.Draft(
							id: UUID(-22),
							residenceID: UUID(-21),
							vehicleID: nil,
							name: "HVAC Filter",
							dueDate: dueDate,
							shouldNotify: true,
							notificationIdentifier: "hvac-id"
						)
					}
				}

				// Set reminder interval to weekly
				let settings = try await database.read { db in
					try AppSettings.fetchAll(db).first
				}
				let settingsRow = try #require(settings)
				let weeklyInterval = ReminderInterval.weekly
				try await database.write { db in
					try AppSettings.find(settingsRow.id)
						.update { $0.reminderInterval = weeklyInterval }
						.execute(db)
				}

				// Create a stale pending request that should be cleaned up
				let staleRequest = UNNotificationRequest(
					identifier: "stale-old-uuid",
					content: UNNotificationContent(),
					trigger: nil
				)

				let (manager, mock) = makeManager(pendingRequests: [staleRequest])
				await manager.refreshAllNotifications()

				// Stale request should have been removed
				let allRemoved = mock.removedIdentifiers.flatMap { $0 }
				#expect(allRemoved.contains("stale-old-uuid"))

				// Maintenance item should have been scheduled
				let addedIds = mock.addedRequests.map(\.identifier)
				#expect(addedIds.contains("hvac-id"))

				// Update reminder should have been scheduled
				#expect(addedIds.contains(NotificationManager.reminderNotificationIdentifier))
			}

			@Test("refreshAllNotifications cancels reminder when interval is .none")
			func refreshAllCancelsReminder() async throws {
				// Default AppSettings has .none interval — no seeding needed
				let (manager, mock) = makeManager()
				await manager.refreshAllNotifications()

				// Reminder should have been canceled, not scheduled
				let addedIds = mock.addedRequests.map(\.identifier)
				#expect(!addedIds.contains(NotificationManager.reminderNotificationIdentifier))

				let allRemoved = mock.removedIdentifiers.flatMap { $0 }
				#expect(allRemoved.contains(NotificationManager.reminderNotificationIdentifier))
			}

			// MARK: nextQuarterStartDate

			@Test(
				"nextQuarterStartDate returns correct next quarter",
				arguments: [
					(1, 4, true), // Jan -> Apr same year
					(3, 4, true), // Mar -> Apr same year
					(4, 7, true), // Apr -> Jul same year
					(6, 7, true), // Jun -> Jul same year
					(7, 10, true), // Jul -> Oct same year
					(9, 10, true), // Sep -> Oct same year
					(10, 1, false), // Oct -> Jan next year
					(12, 1, false) // Dec -> Jan next year
				]
			)
			func nextQuarter(month: Int, expectedMonth: Int, sameYear: Bool) {
				var components = DateComponents()
				components.year = 2026
				components.month = month
				components.day = 15
				let date = Calendar.current.date(from: components)!

				let result = NotificationManager.nextQuarterStartDate(from: date)
				let resultComponents = Calendar.current.dateComponents(
					[.year, .month, .day, .hour], from: result
				)

				#expect(resultComponents.month == expectedMonth)
				#expect(resultComponents.day == 1)
				#expect(resultComponents.hour == 8)
				#expect(resultComponents.year == (sameYear ? 2026 : 2027))
			}
		}
	}
}
