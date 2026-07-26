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

		// Value as loaded, so `save()` can leave the field out of the update when untouched. A
		// value this device cannot decrypt reads as empty, and writing that back would erase it
		// for whoever shared the profile. See `LegacySensitiveText`.
		private let loadedAccountNumber: String
		var url: String
		var notes: String

		// Profile switching support
		@ObservationIgnored
		@FetchAll(ProfileShare.none, animation: .default) var profiles
		var currentProfileID: UUID
		var supportsProfileSwitching: Bool { true }
		var itemNameForProfilePicker: String {
			let name = institution.isNotEmpty ? "\(institution) - \(accountType.rawValue)" : "this investment account"
			return name
		}

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
			self.loadedAccountNumber = account.accountNumber
			self.isActive = account.isActive
			self.url = account.url
			self.notes = account.notes
			self.currentProfileID = account.profileID
		}

		func loadProfiles() async {
			await ProfileShare.reload(into: $profiles)
		}

		func save() {
			do {
				try database.write { db in
					if isNew {
						try InvestmentAccount.insert {
							InvestmentAccount.Draft(
								id: account.id,
								profileID: currentProfileID,
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
								$0.profileID = currentProfileID
								$0.institution = institution
								$0.accountType = accountType
								if accountNumber != loadedAccountNumber {
									$0.accountNumber = #bind(accountNumber)
								}
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
