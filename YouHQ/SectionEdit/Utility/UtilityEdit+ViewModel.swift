//
//  UtilityEdit+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import SQLiteData
import SwiftUI

extension UtilityEdit {
	@Observable
	final class ViewModel: SectionEditViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		let utility: Utility
		let isNew: Bool

		var type: UtilityType
		var provider: String
		var accountNumber: String
		var monthlyCost: Double?
		var url: String
		var notes: String

		var title: String {
			isNew ? "Add Utility" : "Edit Utility"
		}

		var isValid: Bool {
			true
		}

		var deleteConfirmationMessage: String {
			"Are you sure you want to delete \(provider) - \(type.rawValue.capitalized)?"
		}

		init(utility: Utility, isNew: Bool) {
			self.utility = utility
			self.isNew = isNew
			self.type = utility.type
			self.provider = utility.provider
			self.accountNumber = utility.accountNumber
			self.monthlyCost = utility.approximateMonthlyCost
			self.url = utility.url
			self.notes = utility.notes
		}

		func save() {
			do {
				try database.write { db in
					if isNew {
						// Insert new record
						try Utility.insert {
							Utility.Draft(
								id: utility.id,
								residenceID: utility.residenceID,
								type: type,
								provider: provider,
								accountNumber: accountNumber,
								approximateMonthlyCost: monthlyCost,
								backgroundColor: utility.backgroundColor,
								url: url,
								notes: notes
							)
						}
						.execute(db)
						Analytics.sendSignal(.residenceUtilityCreated)
					} else {
						// Update existing record
						try Utility.find(utility.id)
							.update {
								$0.type = type
								$0.provider = provider
								$0.accountNumber = accountNumber
								$0.approximateMonthlyCost = monthlyCost
								$0.url = url
								$0.notes = notes
							}
							.execute(db)
					}
				}
			} catch {
				Analytics.logError(id: .utilitySaveFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}

		func cancel() {
			// Draft items don't need cleanup since they're never in DB
		}

		func delete() {
			do {
				try database.write { db in
					try Utility.find(utility.id)
						.delete()
						.execute(db)
				}
				Analytics.sendSignal(.residenceUtilityDeleted)
			} catch {
				Analytics.logError(id: .utilityDeleteFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}
	}
}
