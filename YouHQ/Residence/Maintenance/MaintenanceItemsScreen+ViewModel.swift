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

		let residenceID: UUID
		var isShowingEditSheet = false
		var isShowingCompleteAlert = false
		var itemToEdit: MaintenanceItem?
		var itemToComplete: MaintenanceItem?
		var isNewItem = false

		init(residenceID: UUID) {
			self.residenceID = residenceID
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
				try await $maintenanceItems.load(
					MaintenanceItem
						.where { $0.residenceID.eq(residenceID) }
						.order { $0.nextDueDate },
					animation: .default
				)
			}
		}

		func showAddMaintenanceItemSheet() {
			// Create a draft maintenance item in memory (not in database)
			let draftItem = MaintenanceItem(
				id: UUID(),
				residenceID: residenceID,
				vehicleID: nil,
				name: "",
				itemDescription: "",
				intervalType: .month,
				intervalValue: 1,
				lastCompletedAt: nil,
				nextDueDate: nil,
				shouldNotify: false,
				notificationIdentifier: "",
				backgroundColor: "yellow",
				url: "",
				notes: ""
			)
			itemToEdit = draftItem
			isNewItem = true
			isShowingEditSheet = true
		}

		func editMaintenanceItem(_ item: MaintenanceItem) {
			itemToEdit = item
			isNewItem = false
			isShowingEditSheet = true
		}

		func showCompleteAlert(for item: MaintenanceItem) {
			itemToComplete = item
			isShowingCompleteAlert = true
		}

		func deleteMaintenanceItem(_ item: MaintenanceItem) {
			withErrorReporting {
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

					// Update item
					try MaintenanceItem.find(item.id)
						.update {
							$0.lastCompletedAt = completedAt
							$0.nextDueDate = nextDue
						}
						.execute(db)
				}

				// Reschedule notification with the new due date
				let updatedItem = try database.read { db in
					try MaintenanceItem.find(item.id).fetchOne(db)
				}

				if let updatedItem {
					Task {
						_ = try await NotificationManager.shared
							.scheduleNotification(for: updatedItem)
					}
				}
			}
			isShowingCompleteAlert = false
		}
	}
}
