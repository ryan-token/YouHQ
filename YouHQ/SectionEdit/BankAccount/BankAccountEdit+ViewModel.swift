//
//  BankAccountEdit+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

extension BankAccountEdit {
	@Observable
	final class ViewModel: SectionEditViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		let account: BankAccount
		let isNew: Bool

		var bankName: String
		var accountType: BankAccountType
		var accountNumber: String
		var routingNumber: String

		// Values as loaded, so `save()` can leave untouched fields out of the update. A value
		// this device cannot decrypt reads as empty, and writing that back would erase it for
		// whoever shared the profile. See `LegacySensitiveText`.
		private let loadedAccountNumber: String
		private let loadedRoutingNumber: String
		var isActive: Bool
		var url: String
		var notes: String

		// Profile switching support
		@ObservationIgnored
		@FetchAll(ProfileShare.none, animation: .default) var profiles
		var currentProfileID: UUID
		var supportsProfileSwitching: Bool { true }
		var itemNameForProfilePicker: String {
			let name = bankName.isNotEmpty ? "\(bankName) - \(accountType.rawValue)" : "this bank account"
			return name
		}

		var title: String {
			isNew ? "Add Bank Account" : "Edit Bank Account"
		}

		var isValid: Bool {
			true
		}

		var deleteConfirmationMessage: String {
			"Are you sure you want to delete \(bankName) - \(accountType.rawValue)?"
		}

		init(account: BankAccount, isNew: Bool) {
			self.account = account
			self.isNew = isNew
			self.bankName = account.bankName
			self.accountType = account.accountType
			self.accountNumber = account.accountNumber
			self.routingNumber = account.routingNumber
			self.loadedAccountNumber = account.accountNumber
			self.loadedRoutingNumber = account.routingNumber
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
						// Insert new record
						try BankAccount.insert {
							BankAccount.Draft(
								id: account.id,
								profileID: currentProfileID,
								bankName: bankName,
								accountType: accountType,
								accountNumber: accountNumber,
								routingNumber: routingNumber,
								isActive: isActive,
								backgroundColor: account.backgroundColor,
								url: url,
								notes: notes
							)
						}
						.execute(db)
						Analytics.sendSignal(.moneyBankAccountCreated)
					} else {
						// Update existing record
						try BankAccount.find(account.id)
							.update {
								$0.profileID = currentProfileID
								$0.bankName = bankName
								$0.accountType = accountType
								if accountNumber != loadedAccountNumber {
									$0.accountNumber = #bind(accountNumber)
								}
								if routingNumber != loadedRoutingNumber {
									$0.routingNumber = #bind(routingNumber)
								}
								$0.isActive = isActive
								$0.url = url
								$0.notes = notes
							}
							.execute(db)
					}
				}
			} catch {
				Analytics.logError(id: .bankAccountSaveFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}

		func cancel() {
			// Draft items don't need cleanup since they're never in DB
		}

		func delete() {
			do {
				try database.write { db in
					try BankAccount.find(account.id)
						.delete()
						.execute(db)
				}
				Analytics.sendSignal(.moneyBankAccountDeleted)
			} catch {
				Analytics.logError(id: .bankAccountDeleteFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}
	}
}
