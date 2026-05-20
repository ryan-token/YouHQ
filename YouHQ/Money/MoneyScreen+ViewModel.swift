//
//  MoneyScreen+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import Sharing
import SQLiteData
import SwiftUI

extension MoneyScreen {
	@Observable
	class ViewModel: ProfileSelection {
		@ObservationIgnored
		@FetchAll(ProfileShare.none, animation: .default) var profiles

		@ObservationIgnored
		@Shared(.appStorage(.selectedProfileIDKey)) var selectedProfileIDString = ""

		// Child view models for entity-specific operations
		var bankAccountViewModel = BankAccountViewModel()
		var investmentAccountViewModel = InvestmentAccountViewModel()
		var healthSavingsAccountViewModel = HealthSavingsAccountViewModel()
		var insuranceViewModel = InsurancePolicyViewModel()
		var otherViewModel = OtherItemViewModel()

		init() {}

		func setSelectedProfileIDString(_ value: String) {
			$selectedProfileIDString.withLock { $0 = value }
		}

		var selectedProfile: ProfileShare? {
			getSelectedProfile()
		}

		var moneyItemsCount: Int {
			let bankAccountCount = bankAccountViewModel.bankAccounts.count
			let investmentAccountsCount = investmentAccountViewModel.investmentAccounts.count
			let healthSavingsAccountsCount = healthSavingsAccountViewModel.healthSavingsAccounts.count
			let policiesCount = insuranceViewModel.insurancePolicies.count
			let otherCount = otherViewModel.others.count
			return bankAccountCount + investmentAccountsCount + healthSavingsAccountsCount + policiesCount + otherCount
		}

		var isShowingSectionEditSheet = false
		var sectionToEdit: EditableSection?
		var sheetTransitionSourceID: String = "addButton"

		// MARK: PROFILE FUNCTIONS

		func loadProfiles() async {
			_ = await withErrorReporting {
				try await $profiles.load(ProfileShare.allWithSyncMetadata, animation: .default)
			}
		}

		// MARK: MONEY ACCOUNT FUNCTIONS

		func loadMoneyData() async {
			guard let profileID = selectedProfile?.profile.id else { return }
			await loadAllData(for: profileID)
		}

		private func loadAllData(for profileID: UUID) async {
			await bankAccountViewModel.load(for: profileID)
			await investmentAccountViewModel.load(for: profileID)
			await healthSavingsAccountViewModel.load(for: profileID)

			// Load standalone insurance policies (not tied to residence or vehicle)
			_ = await withErrorReporting {
				try await insuranceViewModel.$insurancePolicies.load(
					InsurancePolicy
						.where {
							$0.profileID.eq(profileID)
								.and($0.residenceID.is(nil))
								.and($0.vehicleID.is(nil))
						}
						.order { $0.type },
					animation: .default
				)
			}

			// Load 'Other' items tied to Money category
			await otherViewModel.loadCategory(for: .money, profileID: profileID)
		}

		// MARK: SHEET PRESENTATION

		func showAddBankAccountSheet(sourceID: String = "addButton") {
			guard let profileID = selectedProfile?.profile.id else { return }
			sectionToEdit = .bankAccountDraft(bankAccountViewModel.createDraft(for: profileID))
			sheetTransitionSourceID = sourceID
			isShowingSectionEditSheet = true
		}

		func showAddInvestmentAccountSheet(sourceID: String = "addButton") {
			guard let profileID = selectedProfile?.profile.id else { return }
			sectionToEdit = .investmentAccountDraft(investmentAccountViewModel.createDraft(for: profileID))
			sheetTransitionSourceID = sourceID
			isShowingSectionEditSheet = true
		}

		func showAddHealthSavingsAccountSheet(sourceID: String = "addButton") {
			guard let profileID = selectedProfile?.profile.id else { return }
			sectionToEdit = .healthSavingsAccountDraft(
				healthSavingsAccountViewModel.createDraft(for: profileID)
			)
			sheetTransitionSourceID = sourceID
			isShowingSectionEditSheet = true
		}

		func showAddInsurancePolicySheet(sourceID: String = "addButton") {
			guard let profileID = selectedProfile?.profile.id else { return }
			sectionToEdit = .insurancePolicyDraft(
				InsurancePolicy(id: UUID(), profileID: profileID, type: .health)
			)
			sheetTransitionSourceID = sourceID
			isShowingSectionEditSheet = true
		}

		func showAddOtherSheet(sourceID: String = "addButton") {
			guard let profileID = selectedProfile?.profile.id else { return }
			sectionToEdit = .otherDraft(
				otherViewModel.createCategoryDraft(for: .money, profileID: profileID)
			)
			sheetTransitionSourceID = sourceID
			isShowingSectionEditSheet = true
		}
	}
}
