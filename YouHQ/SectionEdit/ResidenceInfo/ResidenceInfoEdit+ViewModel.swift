//
//  ResidenceInfoEdit+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import PhotosUI
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
		var costType: CostType
		var monthlyCost: Double?
		var url: String
		var notes: String
		var photoData: Data?
		var photoItem: PhotosPickerItem?

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
			self.photoData = nil
			self.photoItem = nil
			loadExistingPhotoData()
		}

		func save() {
			withErrorReporting {
				try database.write { db in
					try Residence.find(residence.id)
						.update {
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

					try updateAsset(in: db)
				}
			}
		}

		func cancel() {
			// Don't delete residences on cancel
		}

		func delete() {
			withErrorReporting {
				try database.write { db in
					try Residence.find(residence.id)
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
						.where { $0.residenceID.eq(residence.id) }
						.fetchOne(db)
				}
			}
			photoData = existingAsset?.imageData
		}

		private func updateAsset(in db: Database) throws {
			try Asset
				.where { $0.residenceID.eq(residence.id) }
				.delete()
				.execute(db)

			if let photoData {
				try Asset.insert {
					Asset.Draft(
						id: UUID(),
						profileID: residence.profileID,
						residenceID: residence.id,
						vehicleID: nil,
						insurancePolicyID: nil,
						maintenanceItemID: nil,
						deviceID: nil,
						otherID: nil,
						imageData: photoData
					)
				}
				.execute(db)
			}
		}
	}
}
