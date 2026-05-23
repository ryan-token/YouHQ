//
//  HealthSavingsAccountViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

@Observable
class HealthSavingsAccountViewModel {
	@ObservationIgnored
	@Dependency(\.defaultDatabase) private var database

	@ObservationIgnored
	@FetchAll(HealthSavingsAccount.none, animation: .default) var healthSavingsAccounts

	func load(for profileID: UUID) async {
		_ = await withErrorReporting {
			try await $healthSavingsAccounts.load(
				HealthSavingsAccount
					.where { $0.profileID.eq(profileID) }
					.order { $0.institution },
				animation: .default
			)
		}
	}

	func createDraft(for profileID: UUID) -> HealthSavingsAccount {
		HealthSavingsAccount(
			id: UUID(),
			profileID: profileID,
			accountType: .hsa
		)
	}

	func delete(_ account: HealthSavingsAccount) {
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

	func updateBackgroundColor(_ color: Color, for account: HealthSavingsAccount) {
		withErrorReporting {
			try database.write { db in
				try HealthSavingsAccount.find(account.id)
					.update { $0.backgroundColor = color.databaseValue }
					.execute(db)
			}

			Analytics.sendSignal(.itemBackgroundColorChanged)
		}
	}
}
