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

		let originalProfileID: UUID
		var selectedProfileID: UUID
		var type: VehicleType = .car
		var subType: VehicleSubType = .gas
		var make: String = ""
		var model: String = ""
		var year: String = ""
		var color: String = ""
		var backgroundColor: Color = .teal
		var vin: String = ""
		var costType: VehicleCostType = .owned
		var monthlyCost: Double?
		var url: String = ""
		var notes: String = ""
		var photoPicker = PhotoPickerViewModel()

		// Profile switching support
		@ObservationIgnored
		@FetchAll(ProfileShare.none, animation: .default) var profiles

		var isValid: Bool {
			make.trimmingCharacters(in: .whitespaces).isNotEmpty
		}

		var isSavingToOriginalProfile: Bool {
			selectedProfileID == originalProfileID
		}

		init(profileID: UUID) {
			self.originalProfileID = profileID
			self.selectedProfileID = profileID
		}

		func loadProfiles() async {
			await ProfileShare.reload(into: $profiles)
		}

		func save() -> Vehicle? {
			var savedVehicle: Vehicle?
			do {
				try database.write { db in
					let vehicleID = UUID()
					try Vehicle.insert {
						Vehicle.Draft(
							id: vehicleID,
							profileID: selectedProfileID,
							type: type,
							subType: subType,
							make: make,
							model: model,
							year: year.isEmpty ? nil : year,
							color: color.isEmpty ? nil : color,
							vin: vin.isEmpty ? nil : vin,
							monthlyCost: monthlyCost,
							costType: costType,
							backgroundColor: backgroundColor.databaseValue,
							url: url,
							notes: notes
						)
					}
					.execute(db)

					if let photoData = photoPicker.photoData {
						try Asset.insert {
							Asset.Draft(
								id: UUID(),
								profileID: selectedProfileID,
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
				Analytics.logError(id: .vehicleSaveFailed, message: error.localizedDescription)
				reportIssue(error)
			}
			return savedVehicle
		}

	}
}
