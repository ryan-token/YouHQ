//
//  InvestmentAccountViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

@Observable
class InvestmentAccountViewModel {
	@ObservationIgnored
	@Dependency(\.defaultDatabase) private var database

	@ObservationIgnored
	@FetchAll(InvestmentAccount.none, animation: .default) var investmentAccounts

	func load(for profileID: UUID) async {
		_ = await withErrorReporting {
			try await $investmentAccounts.load(
				InvestmentAccount
					.where { $0.profileID.eq(profileID) }
					.order { $0.institution },
				animation: .default
			)
		}
	}

	func createDraft(for profileID: UUID) -> InvestmentAccount {
		InvestmentAccount(
			id: UUID(),
			profileID: profileID,
			institution: "",
			accountType: .brokerage,
			accountNumber: "",
			isActive: true,
			backgroundColor: "mint",
			url: "",
			notes: ""
		)
	}

	func delete(_ account: InvestmentAccount) {
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

	func updateBackgroundColor(_ color: Color, for account: InvestmentAccount) {
		withErrorReporting {
			try database.write { db in
				try InvestmentAccount.find(account.id)
					.update { $0.backgroundColor = color.databaseValue }
					.execute(db)
			}

			Analytics.sendSignal(.itemBackgroundColorChanged)
		}
	}
}
