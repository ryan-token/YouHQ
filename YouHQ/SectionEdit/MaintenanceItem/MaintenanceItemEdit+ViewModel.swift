//
//  MaintenanceItemEdit+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import SQLiteData
import SwiftUI
import UserNotifications

extension MaintenanceItemEdit {
	@Observable
	final class ViewModel: SectionEditViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		let item: MaintenanceItem
		let isNew: Bool

		var name: String
		var itemDescription: String
		var intervalType: MaintenanceIntervalType
		var intervalValue: Int
		var lastCompletedAt: Date?
		var dueDate: Date?
		var shouldNotify: Bool
		var isUsingManualDueDate: Bool
		var url: String
		var notes: String
		var photoPicker = PhotoPickerViewModel()

		var isShowingPermissionAlert = false
		private var previousShouldNotify: Bool

		/// Date shown in the next-due-date picker. Reading it returns the manual
		/// override when set, otherwise the automatically calculated value.
		/// Writing it stores the manual value and switches to manual mode.
		var displayedDueDate: Date {
			get { isUsingManualDueDate ? (dueDate ?? calculatedNextDueDate) : calculatedNextDueDate }
			set {
				dueDate = newValue
				isUsingManualDueDate = true
			}
		}

		var calculatedNextDueDate: Date {
			let calendar = Calendar.current
			let component = intervalType.calendarComponent
			// Use lastCompletedAt if available, otherwise use current date
			let baseDate = lastCompletedAt ?? Date()
			return calendar.date(
				byAdding: component,
				value: intervalValue,
				to: baseDate
			) ?? baseDate
		}

		var title: String {
			isNew ? "Add Maintenance Item" : "Edit Item"
		}

		var isValid: Bool {
			name.trimmingCharacters(in: .whitespaces).isNotEmpty
		}

		var deleteConfirmationMessage: String {
			"Are you sure you want to delete \(name)?"
		}

		init(item: MaintenanceItem, isNew: Bool) {
			self.item = item
			self.isNew = isNew
			self.name = item.name
			self.itemDescription = item.itemDescription
			self.intervalType = item.intervalType
			self.intervalValue = item.intervalValue
			self.lastCompletedAt = item.lastCompletedAt
			self.shouldNotify = item.shouldNotify
			self.previousShouldNotify = item.shouldNotify
			self.url = item.url
			self.notes = item.notes

			// Calculate initial next due date
			let calculated = {
				let calendar = Calendar.current
				let component = item.intervalType.calendarComponent
				// Use lastCompletedAt if available, otherwise use current date
				let baseDate = item.lastCompletedAt ?? Date()
				return calendar.date(
					byAdding: component,
					value: item.intervalValue,
					to: baseDate
				) ?? baseDate
			}()

			self.dueDate = item.dueDate ?? calculated

			// Check if the stored due date differs from calculated, meaning it's manual
			if let nextDue = item.dueDate {
				let calendar = Calendar.current
				isUsingManualDueDate = !calendar.isDate(
					nextDue,
					inSameDayAs: calculated
				)
			} else {
				isUsingManualDueDate = false
			}

			loadExistingPhotoData()
		}

		func save() {
			do {
				try database.write { db in
					if isNew {
						// Insert new record
						try MaintenanceItem.insert {
							MaintenanceItem.Draft(
								id: item.id,
								residenceID: item.residenceID,
								vehicleID: item.vehicleID,
								name: name,
								itemDescription: itemDescription,
								intervalType: intervalType,
								intervalValue: intervalValue,
								lastCompletedAt: lastCompletedAt,
								dueDate:
									isUsingManualDueDate
									? dueDate : calculatedNextDueDate,
								shouldNotify: shouldNotify,
								notificationIdentifier: item.notificationIdentifier,
								backgroundColor: item.backgroundColor,
								url: url,
								notes: notes
							)
						}
						.execute(db)
						if item.residenceID != nil {
							Analytics.sendSignal(.residenceMaintenanceItemCreated)
						}
					} else {
						// Update existing record
						let newDueDate = isUsingManualDueDate ? dueDate : calculatedNextDueDate

						try MaintenanceItem.find(item.id)
							.update {
								$0.name = name
								$0.itemDescription = itemDescription
								$0.intervalType = intervalType
								$0.intervalValue = intervalValue
								$0.lastCompletedAt = lastCompletedAt
								$0.dueDate = newDueDate
								$0.shouldNotify = shouldNotify
								$0.url = url
								$0.notes = notes
							}
							.execute(db)
						print("[DB] Database update completed")
					}

					try photoPicker.updateAsset(
						in: db,
						link: .maintenanceItem(item)
					)
				}

				// Schedule or cancel notification based on the saved item
				withErrorReporting {
					let savedItem = try database.read { db in
						try MaintenanceItem.find(item.id).fetchOne(db)
					}

					if let savedItem {
						Task {
							_ = try await NotificationManager.shared.scheduleNotification(for: savedItem)
						}
					}
				}
			} catch {
				Analytics.logError(id: .maintenanceItemSaveFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}

		func cancel() {
			// Draft items don't need cleanup since they're never in DB
		}

		func resetToAutomaticDueDate() {
			dueDate = calculatedNextDueDate
			isUsingManualDueDate = false
		}

		func delete() {
			do {
				try database.write { db in
					try MaintenanceItem.find(item.id)
						.delete()
						.execute(db)
				}

				// Cancel notification when deleting item
				Task {
					await NotificationManager.shared.cancelNotification(
						for: item
					)
				}
				if item.residenceID != nil {
					Analytics.sendSignal(.residenceMaintenanceItemDeleted)
				}
			} catch {
				Analytics.logError(id: .maintenanceItemDeleteFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}

		func handleNotifyToggle() {
			// If user is enabling notifications for the first time
			if shouldNotify && !previousShouldNotify {
				Task {
					let status = await NotificationManager.shared.checkAuthorizationStatus()

					switch status {
					case .notDetermined:
						// Request permission for the first time
						do {
							try await NotificationManager.shared.requestAuthorization()
							let newStatus = await NotificationManager.shared.checkAuthorizationStatus()
							if newStatus != .authorized {
								// User denied permission
								await MainActor.run {
									isShowingPermissionAlert = true
									shouldNotify = false
								}
							}
						} catch {
							// Error requesting permission
							await MainActor.run {
								shouldNotify = false
							}
							Analytics.logError(id: .notificationsRequestFailed, message: error.localizedDescription)
						}

					case .denied:
						// Show alert to go to settings
						await MainActor.run {
							isShowingPermissionAlert = true
							shouldNotify = false
						}

					case .authorized, .provisional, .ephemeral:
						// Permission already granted
						break

					@unknown default:
						break
					}
				}
			}
		}

		func openNotificationSettings() {
			NotificationManager.shared.openNotificationSettings()
		}

		private func loadExistingPhotoData() {
			withErrorReporting {
				try database.read { db in
					try photoPicker.loadExistingPhotoData(
						in: db,
						link: .maintenanceItem(item)
					)
				}
			}
		}
	}
}
