//
//  OnboardingReminderView+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 3/10/26.
//

import Dependencies
import SQLiteData
import SwiftUI
import UserNotifications

extension OnboardingReminderView {
	@Observable
	@MainActor
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) private var database

		var selectedInterval: ReminderInterval = .monthly
		var isShowingPermissionAlert = false

		func loadData() {
			withErrorReporting {
				let settings = try database.read { db in
					try AppSettings.fetchAll(db).first
				}
				if let settings, settings.reminderInterval != .none {
					selectedInterval = settings.reminderInterval
				}
			}
		}

		var enableButtonText: String {
			switch selectedInterval {
			case .daily: "Enable Daily Reminder"
			case .weekly: "Enable Weekly Reminder"
			case .monthly: "Enable Monthly Reminder"
			case .quarterly: "Enable Quarterly Reminder"
			case .annually: "Enable Annual Reminder"
			default: "Enable Reminder"
			}
		}

		func enableReminder() async {
			let status = await NotificationManager.shared.checkAuthorizationStatus()

			switch status {
			case .notDetermined:
				do {
					try await NotificationManager.shared.requestAuthorization()
					let newStatus = await NotificationManager.shared.checkAuthorizationStatus()
					if newStatus == .authorized {
						await saveAndSchedule()
					} else {
						isShowingPermissionAlert = true
					}
				} catch {
					Analytics.logError(
						id: .notificationsRequestFailed,
						message: error.localizedDescription
					)
				}

			case .denied:
				isShowingPermissionAlert = true

			case .authorized, .provisional, .ephemeral:
				await saveAndSchedule()

			@unknown default:
				break
			}
		}

		private func saveAndSchedule() async {
			let interval = selectedInterval
			await withErrorReporting {
				guard let settings = try await database.read({ db in
					try AppSettings.fetchAll(db).first
				}) else { return }

				try await NotificationManager.shared.scheduleReminderNotification(interval: interval)

				try await database.write { db in
					try AppSettings.find(settings.id)
						.update {
							$0.reminderInterval = interval
						}
						.execute(db)
				}
			}
		}
	}
}
