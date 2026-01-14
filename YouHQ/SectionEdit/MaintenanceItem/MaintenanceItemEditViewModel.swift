//
//  MaintenanceItemEditViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import SQLiteData
import SwiftUI

@Observable
final class MaintenanceItemEditViewModel: SectionEditViewModel {
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
		isNew ? "Add Maintenance Item" : "Edit Maintenance Item"
	}

	var isValid: Bool {
		name.trimmingCharacters(in: .whitespaces).isNotEmpty
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
	}

	func save() {
		withErrorReporting {
			try database.write { db in
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
		}
	}

	func cancel() {
		if isNew {
			deleteItem()
		}
	}

	func resetToAutomaticDueDate() {
		nextDueDate = calculatedNextDueDate
		isUsingManualDueDate = false
	}

	private func deleteItem() {
		withErrorReporting {
			try database.write { db in
				try MaintenanceItem.find(item.id)
					.delete()
					.execute(db)
			}
		}
	}
}
