//
//  MaintenanceItemViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/19/26.
//

import SQLiteData
import SwiftUI

@Observable
class MaintenanceItemViewModel {
	@ObservationIgnored
	@Dependency(\.defaultDatabase) private var database

	@ObservationIgnored
	@FetchAll(MaintenanceItem.none, animation: .default) var maintenanceItems

	var draftMaintenanceItem: MaintenanceItem?

	func load(for residenceID: UUID) async {
		_ = await withErrorReporting {
			try await $maintenanceItems.load(
				MaintenanceItem
					.where { $0.residenceID.eq(residenceID) }
					.order { $0.name },
				animation: .default
			)
		}
	}

	func createDraft(for residenceID: UUID) -> MaintenanceItem {
		MaintenanceItem(
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
			backgroundColor: "yellow",
			url: "",
			notes: ""
		)
	}

	func delete(_ item: MaintenanceItem) {
		withErrorReporting {
			try database.write { db in
				try MaintenanceItem.find(item.id)
					.delete()
					.execute(db)
			}
		}
	}

	func complete(_ item: MaintenanceItem) {
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
		}
	}
}
