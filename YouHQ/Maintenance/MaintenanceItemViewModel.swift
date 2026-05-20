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
	@FetchAll(MaintenanceItem.none, animation: .default) var maintenanceItems

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

	func loadVehicle(for vehicleID: UUID) async {
		_ = await withErrorReporting {
			try await $maintenanceItems.load(
				MaintenanceItem
					.where { $0.vehicleID.eq(vehicleID) }
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
			dueDate: nil,
			shouldNotify: false,
			backgroundColor: "yellow",
			url: "",
			notes: ""
		)
	}

	func createVehicleDraft(for vehicleID: UUID) -> MaintenanceItem {
		MaintenanceItem(
			id: UUID(),
			residenceID: nil,
			vehicleID: vehicleID,
			name: "",
			itemDescription: "",
			intervalType: .month,
			intervalValue: 1,
			lastCompletedAt: nil,
			dueDate: nil,
			shouldNotify: false,
			backgroundColor: "yellow",
			url: "",
			notes: ""
		)
	}
}
