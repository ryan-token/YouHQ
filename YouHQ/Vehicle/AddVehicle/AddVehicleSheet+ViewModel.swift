//
//  AddVehicleSheet+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

extension AddVehicleSheet {
	@Observable
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		let profileID: UUID
		var type: VehicleType = .car
		var subType: VehicleSubType = .gas
		var make: String = ""
		var model: String = ""
		var year: String = ""
		var color: String = ""
		var vin: String = ""
		var costType: VehicleCostType = .owned
		var monthlyCost: Double?
		var url: String = ""
		var notes: String = ""
		var photoPicker = PhotoPickerViewModel()

		var isValid: Bool {
			make.trimmingCharacters(in: .whitespaces).isNotEmpty
		}

		init(profileID: UUID) {
			self.profileID = profileID
		}

		func save() -> Vehicle? {
			var savedVehicle: Vehicle?
			do {
				try database.write { db in
					let vehicleID = UUID()
					try Vehicle.insert {
						Vehicle.Draft(
							id: vehicleID,
							profileID: profileID,
							type: type,
							subType: subType,
							make: make,
							model: model,
							year: year.isEmpty ? nil : year,
							color: color.isEmpty ? nil : color,
							vin: vin.isEmpty ? nil : vin,
							monthlyCost: monthlyCost,
							costType: costType,
							url: url,
							notes: notes
						)
					}
					.execute(db)

					if let photoData = photoPicker.photoData {
						try Asset.insert {
							Asset.Draft(
								id: UUID(),
								profileID: profileID,
								vehicleID: vehicleID,
								imageData: photoData
							)
						}
						.execute(db)
					}
					savedVehicle = try Vehicle.find(vehicleID).fetchOne(db)
				}
				Analytics.sendSignal(.vehicleCreated)
			} catch {
				Analytics.logError(id: .residenceSaveFailed, message: error.localizedDescription)
				reportIssue(error)
			}
			return savedVehicle
		}

	}
}
