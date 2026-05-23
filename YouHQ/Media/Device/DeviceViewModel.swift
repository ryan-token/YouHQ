//
//  DeviceViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

@Observable
class DeviceViewModel {
	@ObservationIgnored
	@Dependency(\.defaultDatabase) private var database

	@ObservationIgnored
	@FetchAll(Device.none, animation: .default) var devices

	func load(for profileID: UUID) async {
		_ = await withErrorReporting {
			try await $devices.load(
				Device
					.where { $0.profileID.eq(profileID) }
					.order { $0.brand },
				animation: .default
			)
		}
	}

	func createDraft(for profileID: UUID) -> Device {
		Device(
			id: UUID(),
			profileID: profileID
		)
	}

	func delete(_ device: Device) {
		do {
			try database.write { db in
				try Device.find(device.id)
					.delete()
					.execute(db)
			}

			Analytics.sendSignal(.mediaDeviceDeleted)
		} catch {
			Analytics.logError(id: .deviceDeleteFailed, message: error.localizedDescription)
			reportIssue(error)
		}
	}

	func updateBackgroundColor(_ color: Color, for device: Device) {
		withErrorReporting {
			try database.write { db in
				try Device.find(device.id)
					.update { $0.backgroundColor = color.databaseValue }
					.execute(db)
			}

			Analytics.sendSignal(.itemBackgroundColorChanged)
		}
	}
}
