//
//  NotificationManager.swift
//  YouHQ
//
//  Created by Ryan Token on 1/20/26.
//

import Dependencies
import SQLiteData
import UserNotifications

#if canImport(UIKit)
	import UIKit
#elseif canImport(AppKit)
	import AppKit
#endif

// MARK: - NotificationCenterProtocol

/// Abstracts `UNUserNotificationCenter` for testability.
protocol NotificationCenterProtocol: Sendable {
	func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
	func authorizationStatus() async -> UNAuthorizationStatus
	func add(_ request: UNNotificationRequest) async throws
	func removePendingNotificationRequests(withIdentifiers identifiers: [String])
	func pendingNotificationRequests() async -> [UNNotificationRequest]
}

extension UNUserNotificationCenter: NotificationCenterProtocol {
	func authorizationStatus() async -> UNAuthorizationStatus {
		await notificationSettings().authorizationStatus
	}
}

// MARK: - NotificationManager

@Observable
final class NotificationManager: Sendable {
	@ObservationIgnored
	@Dependency(\.defaultDatabase) private var database

	private let center: any NotificationCenterProtocol
	static let shared = NotificationManager()

	private init() {
		self.center = UNUserNotificationCenter.current()
	}

	/// Test-only initializer that accepts a mock notification center.
	init(center: any NotificationCenterProtocol) {
		self.center = center
	}

	/// Request notification permissions from the user
	func requestAuthorization() async throws {
		_ = try await center.requestAuthorization(options: [
			.alert, .sound, .badge
		])
	}

	/// Check if notifications are authorized
	func checkAuthorizationStatus() async -> UNAuthorizationStatus {
		await center.authorizationStatus()
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

	// MARK: - Update Reminder Notifications

	/// Fixed identifier for the update reminder notification.
	/// Using a deterministic identifier guarantees that at most one reminder
	/// notification is ever pending
	static let reminderNotificationIdentifier = "com.ryantoken.YouHQ.updateReminder"

	/// Schedule a recurring reminder notification to update YouHQ info.
	func scheduleReminderNotification(interval: ReminderInterval) async throws {
		// If interval is .none, cancel any existing and return
		guard interval != .none else {
			cancelReminderNotification()
			return
		}

		let status = await checkAuthorizationStatus()
		guard status == .authorized else { return }

		let identifier = Self.reminderNotificationIdentifier

		// Remove any existing reminder notification first
		center.removePendingNotificationRequests(withIdentifiers: [identifier])

		// Create notification content
		let content = UNMutableNotificationContent()
		content.title = "Time to Update YouHQ Info"
		content.body = "Keep your info up to date so it's there when you need it."
		content.sound = .default

		// Build date components for the trigger based on interval
		var dateComponents = DateComponents()
		dateComponents.hour = 8
		dateComponents.minute = 0

		var repeats = true

		switch interval {
		case .daily:
			// Every day at 8 AM — hour+minute only
			break
		case .weekly:
			dateComponents.weekday = 2 // Monday
		case .monthly:
			dateComponents.day = 1
		case .quarterly:
			// UNCalendarNotificationTrigger can't express "every 3 months"
			// with repeats: true. Use a non-repeating trigger for the next
			// quarter start; refreshAllNotifications() reschedules on each launch.
			let nextQuarterDate = Self.nextQuarterStartDate()
			dateComponents = Calendar.current.dateComponents(
				[.year, .month, .day], from: nextQuarterDate
			)
			dateComponents.hour = 8
			dateComponents.minute = 0
			repeats = false
		case .annually:
			dateComponents.month = 1
			dateComponents.day = 1
		default:
			return
		}

		let trigger = UNCalendarNotificationTrigger(
			dateMatching: dateComponents,
			repeats: repeats
		)

		let request = UNNotificationRequest(
			identifier: identifier,
			content: content,
			trigger: trigger
		)

		try await center.add(request)
	}

	/// Cancel the update reminder notification
	func cancelReminderNotification() {
		center.removePendingNotificationRequests(withIdentifiers: [Self.reminderNotificationIdentifier])
	}

	// MARK: - Open System Settings

	/// Opens the system notification settings for this app
	func openNotificationSettings() {
		#if os(iOS) || os(visionOS)
			if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
				UIApplication.shared.open(url)
			}
		#elseif os(macOS)
			if let url = URL(
				string:
					"x-apple.systempreferences:com.apple.preference.notifications?id=com.ryantoken.YouHQ"
			) {
				NSWorkspace.shared.open(url)
			}
		#endif
	}

	// MARK: - Refresh All

	/// Refresh notifications for all maintenance items and the update reminder.
	/// This should be called after CloudKit sync or on app launch.
	func refreshAllNotifications() async {
		await withErrorReporting {
			let items = try await database.read { db in
				try MaintenanceItem.fetchAll(db)
			}

			// Build the set of identifiers we expect to be pending so we can
			// remove any stale ones left over from the old random-UUID scheme.
			var knownIdentifiers: Set<String> = [Self.reminderNotificationIdentifier]
			for item in items {
				let id = item.notificationIdentifier.isEmpty
					? item.id.uuidString : item.notificationIdentifier
				knownIdentifiers.insert(id)
			}

			// Cancel any pending notifications whose identifiers we don't recognize.
			let pending = await center.pendingNotificationRequests()
			let staleIdentifiers = pending.map(\.identifier).filter { !knownIdentifiers.contains($0) }
			if staleIdentifiers.isNotEmpty {
				center.removePendingNotificationRequests(withIdentifiers: staleIdentifiers)
			}

			// Refresh maintenance item notifications
			for item in items {
				_ = try await scheduleNotification(for: item)
			}

			// Refresh the update reminder notification
			let settings = try await database.read { db in
				try AppSettings.fetchAll(db).first
			}

			if let settings, settings.reminderInterval != .none {
				try await scheduleReminderNotification(interval: settings.reminderInterval)
			} else {
				cancelReminderNotification()
			}
		}
	}

	// MARK: - Helpers

	static func nextQuarterStartDate(from now: Date = Date()) -> Date {
		let calendar = Calendar.current
		let currentMonth = calendar.component(.month, from: now)
		let quarterStartMonths = [1, 4, 7, 10]
		let nextQuarterMonth = quarterStartMonths.first(where: { $0 > currentMonth })
			?? quarterStartMonths[0]
		var components = calendar.dateComponents([.year], from: now)
		components.month = nextQuarterMonth
		components.day = 1
		components.hour = 8
		if nextQuarterMonth <= currentMonth {
			components.year = (components.year ?? 2026) + 1
		}
		return calendar.date(from: components) ?? now
	}
}
