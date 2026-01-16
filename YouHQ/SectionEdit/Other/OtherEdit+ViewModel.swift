//
//  OtherEdit+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import PhotosUI
import SQLiteData
import SwiftUI

extension OtherEdit {
	@Observable
	final class ViewModel: SectionEditViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		let other: Other
		let isNew: Bool

		var name: String
		var otherDescription: String
		var monthlyCost: Double?
		var url: String
		var notes: String
		var photoData: Data?
		var photoItem: PhotosPickerItem?

		var title: String {
			isNew ? "Add Other" : "Edit Other"
		}

		var isValid: Bool {
			name.trimmingCharacters(in: .whitespaces).isNotEmpty
		}

		let deleteConfirmationMessage = "Are you sure you want to delete this?"

		init(other: Other, isNew: Bool) {
			self.other = other
			self.isNew = isNew
			self.name = other.name
			self.otherDescription = other.otherDescription
			self.monthlyCost = other.monthlyCost
			self.url = other.url
			self.notes = other.notes
			self.photoData = nil
			self.photoItem = nil
			loadExistingPhotoData()
		}

		func save() {
			withErrorReporting {
				try database.write { db in
					try Other.find(other.id)
						.update {
							$0.name = name
							$0.otherDescription = otherDescription
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
			if isNew {
				delete()
			}
		}

		func delete() {
			withErrorReporting {
				try database.write { db in
					try Other.find(other.id)
						.delete()
						.execute(db)
				}
			}
		}

		func handlePhotoItemChange(_ newItem: PhotosPickerItem?) {
			guard let newItem else { return }
			Task {
				if let data = try? await newItem.loadTransferable(type: Data.self) {
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
					existingAsset = try Asset
						.where { $0.otherID.eq(other.id) }
						.fetchOne(db)
				}
			}
			photoData = existingAsset?.imageData
		}

		private func updateAsset(in db: Database) throws {
			try Asset
				.where { $0.otherID.eq(other.id) }
				.delete()
				.execute(db)

			if let photoData {
				try Asset.insert {
					Asset.Draft(
						id: UUID(),
						profileID: other.profileID,
						residenceID: nil,
						vehicleID: nil,
						insurancePolicyID: nil,
						maintenanceItemID: nil,
						deviceID: nil,
						otherID: other.id,
						imageData: photoData
					)
				}
				.execute(db)
			}
		}
	}
}
