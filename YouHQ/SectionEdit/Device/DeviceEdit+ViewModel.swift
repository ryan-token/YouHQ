//
//  DeviceEdit+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

extension DeviceEdit {
	@Observable
	final class ViewModel: SectionEditViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		let device: Device
		let isNew: Bool

		var type: DeviceType
		var brand: String
		var model: String
		var serialNumber: String
		var purchaseDate: Date?

		// Value as loaded, so `save()` can leave the field out of the update when untouched. A
		// value this device cannot decrypt reads as empty, and writing that back would erase it
		// for whoever shared the profile. See `LegacySensitiveText`.
		private let loadedSerialNumber: String
		var url: String
		var notes: String

		// Profile switching support
		@ObservationIgnored
		@FetchAll(ProfileShare.none, animation: .default) var profiles
		var currentProfileID: UUID
		var supportsProfileSwitching: Bool { true }
		var itemNameForProfilePicker: String {
			let displayName = [brand, model].filter { $0.isNotEmpty }.joined(separator: " ")
			return displayName.isEmpty ? "this device" : displayName
		}

		var title: String {
			isNew ? "Add Device" : "Edit Device"
		}

		var isValid: Bool {
			true
		}

		var deleteConfirmationMessage: String {
			let name = [brand, model].filter { $0.isNotEmpty }.joined(separator: " ")
			return "Are you sure you want to delete \(name.isEmpty ? "this device" : name)?"
		}

		init(device: Device, isNew: Bool) {
			self.device = device
			self.isNew = isNew
			self.type = device.type
			self.brand = device.brand
			self.model = device.model
			self.serialNumber = device.serialNumber
			self.loadedSerialNumber = device.serialNumber
			self.purchaseDate = device.purchaseDate
			self.url = device.url
			self.notes = device.notes
			self.currentProfileID = device.profileID
		}

		func loadProfiles() async {
			await ProfileShare.reload(into: $profiles)
		}

		func save() {
			do {
				try database.write { db in
					if isNew {
						// Insert new record
						try Device.insert {
							Device.Draft(
								id: device.id,
								profileID: currentProfileID,
								type: type,
								brand: brand,
								model: model,
								serialNumber: serialNumber,
								purchaseDate: purchaseDate,
								backgroundColor: device.backgroundColor,
								url: url,
								notes: notes
							)
						}
						.execute(db)
						Analytics.sendSignal(.mediaDeviceCreated)
					} else {
						// Update existing record
						try Device.find(device.id)
							.update {
								$0.profileID = currentProfileID
								$0.type = type
								$0.brand = brand
								$0.model = model
								if serialNumber != loadedSerialNumber {
									$0.serialNumber = #bind(serialNumber)
								}
								$0.purchaseDate = purchaseDate
								$0.url = url
								$0.notes = notes
							}
							.execute(db)
					}
				}
			} catch {
				Analytics.logError(id: .deviceSaveFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}

		func cancel() {
			// Draft items don't need cleanup since they're never in DB
		}

		func delete() {
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
	}
}
