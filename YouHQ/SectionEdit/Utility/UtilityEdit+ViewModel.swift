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
			withErrorReporting {
				try database.write { db in
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
		}

		func cancel() {
			if isNew {
				delete()
			}
		}

		func delete() {
			withErrorReporting {
				try database.write { db in
					try Utility.find(utility.id)
						.delete()
						.execute(db)
				}
			}
		}
	}
}
