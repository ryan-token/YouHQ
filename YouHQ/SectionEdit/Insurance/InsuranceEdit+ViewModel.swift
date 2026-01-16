//
//  InsuranceEdit+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import PhotosUI
import SQLiteData
import SwiftUI

extension InsuranceEdit {
	@Observable
	final class ViewModel: SectionEditViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		let policy: InsurancePolicy
		let isNew: Bool

		var type: InsurancePolicyType
		var provider: String
		var policyNumber: String
		var monthlyCost: Double?
		var deductible: Double?
		var coverageAmount: Double?
		var renewalDate: Date?
		var hasRenewalDate: Bool
		var url: String
		var notes: String
		var photoData: Data?
		var photoItem: PhotosPickerItem?

		var title: String {
			isNew ? "Add Policy" : "Edit Policy"
		}

		var isValid: Bool {
			true
		}

		var deleteConfirmationMessage: String {
			"Are you sure you want to delete this \(provider) \(type) policy?"
		}

		init(policy: InsurancePolicy, isNew: Bool) {
			self.policy = policy
			self.isNew = isNew
			self.type = policy.type
			self.provider = policy.provider
			self.policyNumber = policy.policyNumber
			self.monthlyCost = policy.monthlyCost
			self.deductible = policy.deductible
			self.coverageAmount = policy.coverageAmount
			self.renewalDate = policy.renewalDate
			self.hasRenewalDate = policy.renewalDate != nil
			self.url = policy.url
			self.notes = policy.notes
			self.photoData = nil
			self.photoItem = nil
			loadExistingPhotoData()
		}

		func save() {
			withErrorReporting {
				try database.write { db in
					try InsurancePolicy.find(policy.id)
						.update {
							$0.type = type
							$0.provider = provider
							$0.policyNumber = policyNumber
							$0.monthlyCost = monthlyCost
							$0.deductible = deductible
							$0.coverageAmount = coverageAmount
							$0.renewalDate = hasRenewalDate ? renewalDate : nil
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
					try InsurancePolicy.find(policy.id)
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
						.where { $0.insurancePolicyID.eq(policy.id) }
						.fetchOne(db)
				}
			}
			photoData = existingAsset?.imageData
		}

		private func updateAsset(in db: Database) throws {
			try Asset
				.where { $0.insurancePolicyID.eq(policy.id) }
				.delete()
				.execute(db)

			if let photoData {
				try Asset.insert {
					Asset.Draft(
						id: UUID(),
						profileID: policy.profileID,
						residenceID: nil,
						vehicleID: nil,
						insurancePolicyID: policy.id,
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
