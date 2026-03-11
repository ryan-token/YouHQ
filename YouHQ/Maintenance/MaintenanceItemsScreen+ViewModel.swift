//
//  MaintenanceItemsScreen+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/13/26.
//

import SQLiteData
import SwiftUI

extension MaintenanceItemsScreen {
	@Observable
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) private var database

		@ObservationIgnored
		@FetchAll(MaintenanceItem.none, animation: .default)
		var maintenanceItems

		let residenceID: UUID?
		let vehicleID: UUID?
		var isShowingEditSheet = false
		var isShowingCompleteAlert = false
		var draftMaintenanceItem: MaintenanceItem?
		var itemToComplete: MaintenanceItem?
		var isNewItem = false
		var sheetTransitionSourceID: String = "addButton"

		init(residenceID: UUID?, vehicleID: UUID?) {
			self.residenceID = residenceID
			self.vehicleID = vehicleID
		}

		var pastDueItems: [MaintenanceItem] {
			maintenanceItems.filter { $0.isPastDue }
		}

		var upcomingItems: [MaintenanceItem] {
			maintenanceItems.filter { $0.isUpcoming && !$0.isPastDue }
		}

		var otherItems: [MaintenanceItem] {
			maintenanceItems.filter { !$0.isPastDue && !$0.isUpcoming }
		}

		func loadData() async {
			_ = await withErrorReporting {
				if let residenceID {
					try await $maintenanceItems.load(
						MaintenanceItem
							.where { $0.residenceID.eq(residenceID) }
							.order { $0.dueDate },
						animation: .default
					)
				} else if let vehicleID {
					try await $maintenanceItems.load(
						MaintenanceItem
							.where { $0.vehicleID.eq(vehicleID) }
							.order { $0.dueDate },
						animation: .default
					)
				}
			}
		}

		func showAddMaintenanceItemSheet() {
			// Create a draft maintenance item in memory (not in database)
			sheetTransitionSourceID = "addButton"
			draftMaintenanceItem = MaintenanceItem(
				id: UUID(),
				residenceID: residenceID,
				vehicleID: vehicleID,
				name: "",
				itemDescription: "",
				intervalType: .month,
				intervalValue: 1,
				lastCompletedAt: nil,
				dueDate: nil,
				shouldNotify: false,
				notificationIdentifier: "",
				backgroundColor: "yellow",
				url: "",
				notes: ""
			)
			isNewItem = true
			isShowingEditSheet = true
		}

		func editMaintenanceItem(_ item: MaintenanceItem) {
			draftMaintenanceItem = item
			isNewItem = false
			sheetTransitionSourceID = item.id.uuidString
			isShowingEditSheet = true
		}

		func showCompleteAlert(for item: MaintenanceItem) {
			itemToComplete = item
			isShowingCompleteAlert = true
		}

		func deleteMaintenanceItem(_ item: MaintenanceItem) {
			do {
				try database.write { db in
					try MaintenanceItem.find(item.id)
						.delete()
						.execute(db)
				}

				Analytics.sendSignal(.residenceMaintenanceItemCreated)

				// Cancel notification when deleting item
				Task {
					await NotificationManager.shared.cancelNotification(
						for: item
					)
				}
			} catch {
				Analytics.logError(id: .maintenanceItemDeleteFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}

		func completeMaintenanceItem(_ item: MaintenanceItem) {
			withErrorReporting {
				try database.write { db in
					let completedAt = Date()
					let nextDue = item.calculateNextDueDate(from: completedAt)

					// Create completion record
					try MaintenanceCompletion.insert {
						MaintenanceCompletion.Draft(
							id: UUID(),
							maintenanceItemID: item.id,
							completedAt: completedAt,
							notes: ""
						)
					}
					.execute(db)

					// Due to changes in Swift 6.3, the compiler can no longer automatically promote
					// some values into query expressions, particularly when it comes to UPDATE queries.
					// To mitigate this, use '#bind' to explicitly wrap this value in a query expression: '$0.column = #bind(value)'
					// https://tinyurl.com/4j78225v
					try MaintenanceItem.find(item.id)
						.update {
							$0.lastCompletedAt = #bind(completedAt)
							$0.dueDate = #bind(nextDue)
						}
						.execute(db)
				}

				// Reschedule notification with the new due date
				let updatedItem = try database.read { db in
					try MaintenanceItem.find(item.id).fetchOne(db)
				}

				if let updatedItem {
					Task {
						_ = try await NotificationManager.shared.scheduleNotification(for: updatedItem)
					}
				}
			}
			isShowingCompleteAlert = false
		}
	}
}
