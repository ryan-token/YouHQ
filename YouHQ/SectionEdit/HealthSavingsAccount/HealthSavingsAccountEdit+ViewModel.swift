//
//  HealthSavingsAccountEdit+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

extension HealthSavingsAccountEdit {
	@Observable
	final class ViewModel: SectionEditViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		let account: HealthSavingsAccount
		let isNew: Bool

		var accountType: HealthSavingsAccountType
		var institution: String
		var accountNumber: String
		var isActive: Bool
		var url: String
		var notes: String

		// Profile switching support
		@ObservationIgnored
		@FetchAll(ProfileShare.none, animation: .default) var profiles
		var currentProfileID: UUID
		var supportsProfileSwitching: Bool { true }
		var itemNameForProfilePicker: String {
			let name = institution.isNotEmpty ? "\(institution) - \(accountType.rawValue)" : "this account"
			return name
		}

		var title: String {
			isNew ? "Add HSA/FSA" : "Edit HSA/FSA"
		}

		var isValid: Bool {
			true
		}

		var deleteConfirmationMessage: String {
			"Are you sure you want to delete \(institution) - \(accountType.rawValue)?"
		}

		init(account: HealthSavingsAccount, isNew: Bool) {
			self.account = account
			self.isNew = isNew
			self.accountType = account.accountType
			self.institution = account.institution
			self.accountNumber = account.accountNumber
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
						try HealthSavingsAccount.insert {
							HealthSavingsAccount.Draft(
								id: account.id,
								profileID: currentProfileID,
								accountType: accountType,
								institution: institution,
								accountNumber: accountNumber,
								isActive: isActive,
								backgroundColor: account.backgroundColor,
								url: url,
								notes: notes
							)
						}
						.execute(db)
						Analytics.sendSignal(.moneyHSACreated)
					} else {
						try HealthSavingsAccount.find(account.id)
							.update {
								$0.profileID = currentProfileID
								$0.accountType = accountType
								$0.institution = institution
								$0.accountNumber = #bind(accountNumber)
								$0.isActive = isActive
								$0.url = url
								$0.notes = notes
							}
							.execute(db)
					}
				}
			} catch {
				Analytics.logError(id: .hsaSaveFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}

		func cancel() {
			// Draft items don't need cleanup since they're never in DB
		}

		func delete() {
			do {
				try database.write { db in
					try HealthSavingsAccount.find(account.id)
						.delete()
						.execute(db)
				}
				Analytics.sendSignal(.moneyHSADeleted)
			} catch {
				Analytics.logError(id: .hsaDeleteFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}
	}
}
