//
//  NotificationSettingsView+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 3/10/26.
//

import Dependencies
import SQLiteData
import SwiftUI
import UserNotifications

extension NotificationSettingsView {
	@Observable
	@MainActor
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) private var database

		var selectedInterval: ReminderInterval = .none
		var isAuthorized = false
		var isShowingPermissionAlert = false

		private var previousInterval: ReminderInterval = .none
		private var appSettingsID: UUID?
		private var isLoading = true

		var permissionStatusText: String {
			isAuthorized ? "Enabled" : "Disabled"
		}

		func loadData() async {
			let status = await NotificationManager.shared.checkAuthorizationStatus()
			isAuthorized = (status == .authorized)

			withErrorReporting {
				let settings = try database.read { db in
					try AppSettings.fetchAll(db).first
				}
				if let settings {
					appSettingsID = settings.id

					if !isAuthorized && settings.reminderInterval != .none {
						// Permissions were revoked — reset to .none
						selectedInterval = .none
						previousInterval = .none
						try database.write { db in
							try AppSettings.find(settings.id)
								.update {
									$0.reminderInterval = ReminderInterval.none
									$0.reminderNotificationIdentifier = ""
								}
								.execute(db)
						}
					} else {
						selectedInterval = settings.reminderInterval
						previousInterval = settings.reminderInterval
					}
				}
			}

			isLoading = false
		}

		func refreshPermissions() async {
			let status = await NotificationManager.shared.checkAuthorizationStatus()
			isAuthorized = (status == .authorized)

			// If permissions were just granted and the user had a pending interval change, save it
			if isAuthorized && selectedInterval != previousInterval {
				await saveAndSchedule()
			}
		}

		func handleIntervalChange() async {
			guard !isLoading else { return }

			if selectedInterval != .none {
				let status = await NotificationManager.shared.checkAuthorizationStatus()

				switch status {
				case .notDetermined:
					do {
						try await NotificationManager.shared.requestAuthorization()
						let newStatus = await NotificationManager.shared.checkAuthorizationStatus()
						if newStatus == .authorized {
							isAuthorized = true
							await saveAndSchedule()
						} else {
							isShowingPermissionAlert = true
						}
					} catch {
						isShowingPermissionAlert = true
					}

				case .denied:
					isShowingPermissionAlert = true

				case .authorized, .provisional, .ephemeral:
					await saveAndSchedule()

				@unknown default:
					break
				}
			} else {
				await saveAndSchedule()
			}
		}

		func revertInterval() {
			selectedInterval = previousInterval
		}

		private func saveAndSchedule() async {
			guard let appSettingsID else { return }
			let interval = selectedInterval
			await withErrorReporting {
				let settings = try await database.read { db in
					try AppSettings.find(appSettingsID).fetchOne(db)
				}
				guard let settings else { return }

				let identifier = try await NotificationManager.shared
					.scheduleReminderNotification(
						interval: interval,
						existingIdentifier: settings.reminderNotificationIdentifier
					)

				try await database.write { db in
					try AppSettings.find(appSettingsID)
						.update {
							$0.reminderInterval = interval
							$0.reminderNotificationIdentifier = identifier
						}
						.execute(db)
				}
			}
			previousInterval = interval
		}
	}
}
