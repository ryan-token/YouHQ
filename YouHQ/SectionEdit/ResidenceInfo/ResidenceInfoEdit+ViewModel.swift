//
//  ResidenceInfoEdit+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import SQLiteData
import SwiftUI

extension ResidenceInfoEdit {
	@Observable
	final class ViewModel: SectionEditViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		let residence: Residence

		var residenceType: ResidenceType
		var isCurrent: Bool
		var street: String
		var unit: String
		var city: String
		var state: String
		var zipCode: String
		var country: String
		var moveInDate: Date?
		var moveOutDate: Date?
		var hasMoveOutDate: Bool
		var costType: ResidenceCostType
		var monthlyCost: Double?
		var url: String
		var notes: String
		var photoPicker = PhotoPickerViewModel()

		// Profile switching support
		var profiles: [ProfileShare] = []
		var currentProfileID: UUID
		var supportsProfileSwitching: Bool { true }
		var itemNameForProfilePicker: String {
			let address = residence.shortAddress
			return address.isNotEmpty ? "this residence (\(address))" : "this residence"
		}

		var title: String {
			"Edit Residence"
		}

		var isValid: Bool {
			street.trimmingCharacters(in: .whitespaces).isNotEmpty
		}

		let deleteConfirmationMessage = """
			Deleting this residence will also delete all utilities, insurance policies, maintenance items, and other items tied to it.
			"""

		init(residence: Residence) {
			self.residence = residence
			self.residenceType = residence.type
			self.isCurrent = residence.isCurrent
			self.street = residence.street
			self.unit = residence.unit
			self.city = residence.city
			self.state = residence.state
			self.zipCode = residence.zipCode
			self.country = residence.country
			self.moveInDate = residence.moveInDate
			self.moveOutDate = residence.moveOutDate
			self.hasMoveOutDate = residence.moveOutDate != nil
			self.costType = residence.costType
			self.monthlyCost = residence.monthlyCost
			self.url = residence.url
			self.notes = residence.notes
			self.currentProfileID = residence.profileID
			loadExistingPhotoData()
		}

		func loadProfiles() async {
			profiles = await loadAllProfiles(from: database)
		}

		func save() {
			withErrorReporting {
				try database.write { db in
					try Residence.find(residence.id)
						.update {
							$0.profileID = currentProfileID
							$0.type = residenceType
							$0.isCurrent = isCurrent
							$0.street = street
							$0.unit = unit
							$0.city = city
							$0.state = state
							$0.zipCode = zipCode
							$0.country = country
							$0.moveInDate = moveInDate
							$0.moveOutDate = hasMoveOutDate ? moveOutDate : nil
							$0.costType = costType
							$0.monthlyCost = monthlyCost
							$0.url = url
							$0.notes = notes
						}
						.execute(db)

					try photoPicker.updateAsset(
						in: db,
						link: .residence(residence)
					)
				}
			}
		}

		func cancel() {
			// Don't delete residences on cancel
		}

		func delete() {
			do {
				// Get all maintenance items for this residence before deletion
				let maintenanceItems = try database.read { db in
					try MaintenanceItem
						.where { $0.residenceID.eq(residence.id) }
						.fetchAll(db)
				}

				// Delete the residence (CASCADE will delete maintenance items)
				try database.write { db in
					try Residence.find(residence.id)
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

				Analytics.sendSignal(.residenceDeleted)
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
						link: .residence(residence)
					)
				}
			}
		}
	}
}
