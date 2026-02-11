//
//  AddResidenceSheet+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/11/26.
//

import SQLiteData
import SwiftUI

extension AddResidenceSheet {
	@Observable
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		var selectedProfileID: UUID
		var type: ResidenceType = .apartment
		var isCurrent: Bool = true
		var street: String = ""
		var unit: String = ""
		var city: String = ""
		var state: String = ""
		var zipCode: String = ""
		var country: String = ""
		var moveInDate: Date?
		var moveOutDate: Date?
		var hasMoveOutDate: Bool = false
		var costType: ResidenceCostType = .rent
		var monthlyCost: Double?
		var url: String = ""
		var notes: String = ""
		var photoPicker = PhotoPickerViewModel()

		// Profile switching support
		var profiles: [ProfileShare] = []

		var isValid: Bool {
			street.trimmingCharacters(in: .whitespaces).isNotEmpty
		}

		init(profileID: UUID) {
			self.selectedProfileID = profileID
		}

		func loadProfiles() async {
			profiles = await loadAllProfiles(from: database)
		}

		func save() -> Residence? {
			var savedResidence: Residence?
			do {
				try database.write { db in
					let residenceID = UUID()
					try Residence.insert {
						Residence.Draft(
							id: residenceID,
							profileID: selectedProfileID,
							type: type,
							street: street,
							unit: unit,
							city: city,
							state: state,
							zipCode: zipCode,
							country: country,
							moveInDate: moveInDate,
							moveOutDate: hasMoveOutDate ? moveOutDate : nil,
							isCurrent: isCurrent,
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
								profileID: selectedProfileID,
								residenceID: residenceID,
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
					savedResidence = try Residence.find(residenceID).fetchOne(db)
				}
				Analytics.sendSignal(.residenceCreated)
			} catch {
				Analytics.logError(id: .residenceSaveFailed, message: error.localizedDescription)
				reportIssue(error)
			}
			return savedResidence
		}

	}
}
