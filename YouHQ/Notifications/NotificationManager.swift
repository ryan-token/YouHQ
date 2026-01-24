//
//  NotificationManager.swift
//  YouHQ
//
//  Created by Ryan Token on 1/20/26.
//

import Dependencies
import SQLiteData
import UserNotifications

@Observable
final class NotificationManager: Sendable {
	@ObservationIgnored
	@Dependency(\.defaultDatabase) private var database

	private let center = UNUserNotificationCenter.current()
	static let shared = NotificationManager()

	private init() {}

	/// Request notification permissions from the user
	func requestAuthorization() async throws {
		_ = try await center.requestAuthorization(options: [
			.alert, .sound, .badge
		])
	}

	/// Check if notifications are authorized
	func checkAuthorizationStatus() async -> UNAuthorizationStatus {
		await center.notificationSettings().authorizationStatus
	}

	/// Schedule a notification for a maintenance item
	/// Returns true if scheduled successfully, false if permission denied
	func scheduleNotification(for item: MaintenanceItem) async throws -> Bool {
		// Only schedule if shouldNotify is true and there's a due date
		guard item.shouldNotify, let dueDate = item.dueDate else {
			// If notification shouldn't be scheduled, cancel any existing one
			await cancelNotification(for: item)
			return true
		}

		// Check authorization status
		let status = await checkAuthorizationStatus()
		guard status == .authorized else { return false }

		// Ensure we have a notification identifier
		let identifier =
			item.notificationIdentifier.isEmpty
			? item.id.uuidString : item.notificationIdentifier

		// Update the identifier in the database if it was empty
		if item.notificationIdentifier.isEmpty {
			withErrorReporting {
				try database.write { db in
					try MaintenanceItem.find(item.id)
						.update {
							$0.notificationIdentifier = identifier
						}
						.execute(db)
				}
			}
		}

		// Remove any existing notification first
		center.removePendingNotificationRequests(withIdentifiers: [identifier])

		// Create notification content
		let content = UNMutableNotificationContent()
		content.title = "Maintenance Due"
		content.body = item.name
		content.sound = .default

		// Schedule for 7 AM on the due date
		var dateComponents = Calendar.current.dateComponents(
			[.year, .month, .day],
			from: dueDate
		)
		dateComponents.hour = 7
		dateComponents.minute = 0

		let trigger = UNCalendarNotificationTrigger(
			dateMatching: dateComponents,
			repeats: false
		)

		let request = UNNotificationRequest(
			identifier: identifier,
			content: content,
			trigger: trigger
		)

		try await center.add(request)
		return true
	}

	/// Cancel a notification for a maintenance item
	func cancelNotification(for item: MaintenanceItem) async {
		let identifier =
			item.notificationIdentifier.isEmpty
			? item.id.uuidString : item.notificationIdentifier
		center.removePendingNotificationRequests(withIdentifiers: [identifier])
	}

	/// Refresh notifications for all maintenance items
	/// This should be called after CloudKit sync or on app launch
	func refreshAllNotifications() async {
		await withErrorReporting {
			let items = try await database.read { db in
				try MaintenanceItem.fetchAll(db)
			}

			for item in items {
				_ = try await scheduleNotification(for: item)
			}
		}
	}
}
