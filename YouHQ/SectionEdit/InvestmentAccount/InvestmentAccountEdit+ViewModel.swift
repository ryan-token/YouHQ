//
//  InvestmentAccountEdit+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

extension InvestmentAccountEdit {
	@Observable
	final class ViewModel: SectionEditViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		let account: InvestmentAccount
		let isNew: Bool

		var institution: String
		var accountType: InvestmentAccountType
		var accountNumber: String
		var isActive: Bool
		var url: String
		var notes: String

		var title: String {
			isNew ? "Add Investment Account" : "Edit Investment Account"
		}

		var isValid: Bool {
			true
		}

		var deleteConfirmationMessage: String {
			"Are you sure you want to delete \(institution) - \(accountType.rawValue)?"
		}

		init(account: InvestmentAccount, isNew: Bool) {
			self.account = account
			self.isNew = isNew
			self.institution = account.institution
			self.accountType = account.accountType
			self.accountNumber = account.accountNumber
			self.isActive = account.isActive
			self.url = account.url
			self.notes = account.notes
		}

		func save() {
			do {
				try database.write { db in
					if isNew {
						try InvestmentAccount.insert {
							InvestmentAccount.Draft(
								id: account.id,
								profileID: account.profileID,
								institution: institution,
								accountType: accountType,
								accountNumber: accountNumber,
								isActive: isActive,
								backgroundColor: account.backgroundColor,
								url: url,
								notes: notes
							)
						}
						.execute(db)
						Analytics.sendSignal(.moneyInvestmentAccountCreated)
					} else {
						try InvestmentAccount.find(account.id)
							.update {
								$0.institution = institution
								$0.accountType = accountType
								$0.accountNumber = accountNumber
								$0.isActive = isActive
								$0.url = url
								$0.notes = notes
							}
							.execute(db)
					}
				}
			} catch {
				Analytics.logError(id: .investmentAccountSaveFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}

		func cancel() {
			// Draft items don't need cleanup since they're never in DB
		}

		func delete() {
			do {
				try database.write { db in
					try InvestmentAccount.find(account.id)
						.delete()
						.execute(db)
				}
				Analytics.sendSignal(.moneyInvestmentAccountDeleted)
			} catch {
				Analytics.logError(id: .investmentAccountDeleteFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}
	}
}
