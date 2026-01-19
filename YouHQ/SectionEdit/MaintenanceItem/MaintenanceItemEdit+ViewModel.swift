//
//  MaintenanceItemEdit+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import SQLiteData
import SwiftUI

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
		var nextDueDate: Date?
		var shouldNotify: Bool
		var isUsingManualDueDate: Bool
		var url: String
		var notes: String
		var photoPicker = PhotoPickerViewModel()

		var calculatedNextDueDate: Date {
			let calendar = Calendar.current
			let component = intervalType.calendarComponent
			return calendar.date(
				byAdding: component,
				value: intervalValue,
				to: Date()
			) ?? Date()
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
			self.url = item.url
			self.notes = item.notes

			// Calculate initial next due date
			let calculated = {
				let calendar = Calendar.current
				let component = item.intervalType.calendarComponent
				return calendar.date(
					byAdding: component,
					value: item.intervalValue,
					to: Date()
				) ?? Date()
			}()

			self.nextDueDate = item.nextDueDate ?? calculated

			// Check if the stored due date differs from calculated, meaning it's manual
			if let nextDue = item.nextDueDate {
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
			withErrorReporting {
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
								nextDueDate:
									isUsingManualDueDate
									? nextDueDate : calculatedNextDueDate,
								shouldNotify: shouldNotify,
								backgroundColor: item.backgroundColor,
								url: url,
								notes: notes
							)
						}
						.execute(db)
					} else {
						// Update existing record
						try MaintenanceItem.find(item.id)
							.update {
								$0.name = name
								$0.itemDescription = itemDescription
								$0.intervalType = intervalType
								$0.intervalValue = intervalValue
								$0.nextDueDate =
									isUsingManualDueDate
									? nextDueDate : calculatedNextDueDate
								$0.shouldNotify = shouldNotify
								$0.url = url
								$0.notes = notes
							}
							.execute(db)
					}

					try photoPicker.updateAsset(
						in: db,
						link: .maintenanceItem(item)
					)
				}
			}
		}

		func cancel() {
			// Draft items don't need cleanup since they're never in DB
		}

		func resetToAutomaticDueDate() {
			nextDueDate = calculatedNextDueDate
			isUsingManualDueDate = false
		}

		func delete() {
			withErrorReporting {
				try database.write { db in
					try MaintenanceItem.find(item.id)
						.delete()
						.execute(db)
				}
			}
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
