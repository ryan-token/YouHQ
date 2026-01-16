//
//  MaintenanceItemEdit+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import PhotosUI
import SQLiteData
import SwiftUI

extension MaintenanceItemEdit {
	@Observable
	final class ViewModel: SectionEditViewModel {
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
		var photoData: Data?
		var photoItem: PhotosPickerItem?

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
			isNew ? "Add Maintenance Item" : "Edit Item"
		}

		var isValid: Bool {
			name.trimmingCharacters(in: .whitespaces).isNotEmpty
		}

		var deleteConfirmationMessage: String {
			"Are you sure you want to delete \(name)?"
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
			self.photoData = nil
			self.photoItem = nil

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

			loadExistingPhotoData()
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

					try updateAsset(in: db)
				}
			}
		}

		func cancel() {
			if isNew {
				delete()
			}
		}

		func resetToAutomaticDueDate() {
			nextDueDate = calculatedNextDueDate
			isUsingManualDueDate = false
		}

		func delete() {
			withErrorReporting {
				try database.write { db in
					try MaintenanceItem.find(item.id)
						.delete()
						.execute(db)
				}
			}
		}

		func handlePhotoItemChange(_ newItem: PhotosPickerItem?) {
			guard let newItem else { return }
			Task {
				if let data = try? await newItem.loadTransferable(
					type: Data.self
				) {
					await MainActor.run {
						self.photoData = data
					}
				}
			}
		}

		func clearPhoto() {
			photoData = nil
			photoItem = nil
		}

		private func loadExistingPhotoData() {
			var existingAsset: Asset?
			withErrorReporting {
				try database.read { db in
					existingAsset =
						try Asset
						.where { $0.maintenanceItemID.eq(item.id) }
						.fetchOne(db)
				}
			}
			photoData = existingAsset?.imageData
		}

		private func updateAsset(in db: Database) throws {
			try Asset
				.where { $0.maintenanceItemID.eq(item.id) }
				.delete()
				.execute(db)

			guard let photoData else { return }
			guard let profileID = try resolveProfileID(in: db) else { return }

			try Asset.insert {
				Asset.Draft(
					id: UUID(),
					profileID: profileID,
					residenceID: nil,
					vehicleID: nil,
					insurancePolicyID: nil,
					maintenanceItemID: item.id,
					deviceID: nil,
					otherID: nil,
					imageData: photoData
				)
			}
			.execute(db)
		}

		private func resolveProfileID(in db: Database) throws -> UUID? {
			if let residenceID = item.residenceID {
				return try Residence.find(residenceID).fetchOne(db)?.profileID
			}
			if let vehicleID = item.vehicleID {
				return try Vehicle.find(vehicleID).fetchOne(db)?.profileID
			}
			return nil
		}
	}
}
