//
//  VehicleInfoEdit+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

extension VehicleInfoEdit {
	@Observable
	final class ViewModel: SectionEditViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		let vehicle: Vehicle

		var vehicleType: VehicleType
		var subType: VehicleSubType
		var make: String
		var model: String
		var year: String
		var color: String
		var vin: String
		var costType: VehicleCostType
		var monthlyCost: Double?
		var url: String
		var notes: String
		var photoPicker = PhotoPickerViewModel()

		var title: String {
			"Edit Vehicle"
		}

		var isValid: Bool {
			make.trimmingCharacters(in: .whitespaces).isNotEmpty
		}

		let deleteConfirmationMessage = """
			Deleting this vehicle will also delete all insurance policies, maintenance items, paint colors, and other items tied to it.
			"""

		init(vehicle: Vehicle) {
			self.vehicle = vehicle
			self.vehicleType = vehicle.type
			self.subType = vehicle.subType
			self.make = vehicle.make
			self.model = vehicle.model
			self.year = vehicle.year ?? ""
			self.color = vehicle.color ?? ""
			self.vin = vehicle.vin ?? ""
			self.costType = vehicle.costType
			self.monthlyCost = vehicle.monthlyCost
			self.url = vehicle.url
			self.notes = vehicle.notes
			loadExistingPhotoData()
		}

		func save() {
			withErrorReporting {
				try database.write { db in
					try Vehicle.find(vehicle.id)
						.update {
							$0.type = vehicleType
							$0.subType = subType
							$0.make = make
							$0.model = model
							$0.year = year.isEmpty ? nil : year
							$0.color = color.isEmpty ? nil : color
							$0.vin = vin.isEmpty ? nil : vin
							$0.monthlyCost = monthlyCost
							$0.costType = costType
							$0.url = url
							$0.notes = notes
						}
						.execute(db)

					try photoPicker.updateAsset(
						in: db,
						link: .vehicle(vehicle)
					)
				}
			}
		}

		func cancel() {
			// Don't delete vehicles on cancel
		}

		func delete() {
			do {
				// Get all maintenance items for this vehicle before deletion
				let maintenanceItems = try database.read { db in
					try MaintenanceItem
						.where { $0.vehicleID.eq(vehicle.id) }
						.fetchAll(db)
				}

				// Delete the vehicle (CASCADE will delete related items)
				try database.write { db in
					try Vehicle.find(vehicle.id)
						.delete()
						.execute(db)
				}

				// Cancel notifications for all maintenance items
				Task {
					for item in maintenanceItems {
						await NotificationManager.shared.cancelNotification(
							for: item
						)
					}
				}

				Analytics.sendSignal(.vehicleDeleted)
			} catch {
				Analytics.logError(id: .residenceDeleteFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}

		private func loadExistingPhotoData() {
			withErrorReporting {
				try database.read { db in
					try photoPicker.loadExistingPhotoData(
						in: db,
						link: .vehicle(vehicle)
					)
				}
			}
		}
	}
}
