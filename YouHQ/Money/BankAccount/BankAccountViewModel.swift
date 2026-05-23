//
//  BankAccountViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

@Observable
class BankAccountViewModel {
	@ObservationIgnored
	@Dependency(\.defaultDatabase) private var database

	@ObservationIgnored
	@FetchAll(BankAccount.none, animation: .default) var bankAccounts

	func load(for profileID: UUID) async {
		_ = await withErrorReporting {
			try await $bankAccounts.load(
				BankAccount
					.where { $0.profileID.eq(profileID) }
					.order { $0.bankName },
				animation: .default
			)
		}
	}

	func createDraft(for profileID: UUID) -> BankAccount {
		BankAccount(
			id: UUID(),
			profileID: profileID,
			accountType: .checking
		)
	}

	func delete(_ account: BankAccount) {
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

	func updateBackgroundColor(_ color: Color, for account: BankAccount) {
		withErrorReporting {
			try database.write { db in
				try BankAccount.find(account.id)
					.update { $0.backgroundColor = color.databaseValue }
					.execute(db)
			}

			Analytics.sendSignal(.itemBackgroundColorChanged)
		}
	}
}
