//
//  InsuranceEdit+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

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
		var photoPicker = PhotoPickerViewModel()

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
			loadExistingPhotoData()
		}

		func save() {
			do {
				try database.write { db in
					if isNew {
						// Insert new record
						try InsurancePolicy.insert {
							InsurancePolicy.Draft(
								id: policy.id,
								profileID: policy.profileID,
								residenceID: policy.residenceID,
								vehicleID: policy.vehicleID,
								type: type,
								provider: provider,
								policyNumber: policyNumber,
								monthlyCost: monthlyCost,
								deductible: deductible,
								coverageAmount: coverageAmount,
								startDate: nil,
								renewalDate: hasRenewalDate ? renewalDate : nil,
								isActive: policy.isActive,
								backgroundColor: policy.backgroundColor,
								url: url,
								notes: notes
							)
						}
						.execute(db)

						if policy.residenceID != nil {
							Analytics.sendSignal(.residenceInsurancePolicyCreated)
						} else if policy.vehicleID != nil {
							Analytics.sendSignal(.vehicleInsurancePolicyCreated)
						}
					} else {
						// Update existing record
						try InsurancePolicy.find(policy.id)
							.update {
								$0.type = type
								$0.provider = provider
								$0.policyNumber = policyNumber
								$0.monthlyCost = monthlyCost
								$0.deductible = deductible
								$0.coverageAmount = coverageAmount
								$0.renewalDate =
									hasRenewalDate ? renewalDate : nil
								$0.url = url
								$0.notes = notes
							}
							.execute(db)
					}

					try photoPicker.updateAsset(
						in: db,
						link: .insurancePolicy(policy)
					)
				}
			} catch {
				Analytics.logError(id: .insurancePolicySaveFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}

		func cancel() {
			// Draft items don't need cleanup since they're never in DB
		}

		func delete() {
			do {
				try database.write { db in
					try InsurancePolicy.find(policy.id)
						.delete()
						.execute(db)
				}
				if policy.residenceID != nil {
					Analytics.sendSignal(.residenceInsurancePolicyDeleted)
				} else if policy.vehicleID != nil {
					Analytics.sendSignal(.vehicleInsurancePolicyDeleted)
				}
			} catch {
				Analytics.logError(id: .insurancePolicyDeleteFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}

		private func loadExistingPhotoData() {
			withErrorReporting {
				try database.read { db in
					try photoPicker.loadExistingPhotoData(
						in: db,
						link: .insurancePolicy(policy)
					)
				}
			}
		}
	}
}
