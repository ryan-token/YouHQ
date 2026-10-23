//
//  MoneyScreen+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import Sharing
import SwiftUI

extension MoneyScreen {
	@Observable
	class ViewModel: ProfileSelection, InitialLoadTracking {
		@ObservationIgnored
		@FetchAll(ProfileShare.none, animation: .default) var profiles

		@ObservationIgnored
		@Shared(.appStorage(.selectedProfileIDKey)) var selectedProfileIDString = ""

		// Child view models for entity-specific operations
		let bankAccountViewModel = BankAccountViewModel()
		let investmentAccountViewModel = InvestmentAccountViewModel()
		let healthSavingsAccountViewModel = HealthSavingsAccountViewModel()
		let insuranceViewModel = InsurancePolicyViewModel()
		let otherViewModel = OtherItemViewModel()

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

		var hasNoMoneyItems: Bool {
			bankAccountViewModel.bankAccounts.isEmpty
				&& investmentAccountViewModel.investmentAccounts.isEmpty
				&& healthSavingsAccountViewModel.healthSavingsAccounts.isEmpty
				&& insuranceViewModel.insurancePolicies.isEmpty
				&& otherViewModel.others.isEmpty
		}

		var isShowingSectionEditSheet = false
		var sectionToEdit: EditableSection?
		var sheetTransitionSourceID: String = "addButton"
		var hasCompletedInitialLoad = false

		// MARK: PROFILE FUNCTIONS

		func loadProfiles() async {
			await ProfileShare.reload(into: $profiles)
		}

		// MARK: MONEY ACCOUNT FUNCTIONS

		func loadMoneyData() async {
			if let profileID = selectedProfile?.profile.id {
				await loadAllData(for: profileID)
			}
			await markInitialLoadComplete()
		}

		private func loadAllData(for profileID: UUID) async {
			async let banks: Void = bankAccountViewModel.load(for: profileID)
			async let investments: Void = investmentAccountViewModel.load(for: profileID)
			async let hsas: Void = healthSavingsAccountViewModel.load(for: profileID)

			// Load standalone insurance policies (not tied to residence or vehicle)
			async let policies: Void? = withErrorReporting {
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
			async let others: Void = otherViewModel.loadCategory(for: .money, profileID: profileID)

			_ = await (banks, investments, hsas, policies, others)
		}

		// MARK: SHEET PRESENTATION

		func showSectionEditSheet(for section: EditableSection, sourceID: String) {
			sectionToEdit = section
			sheetTransitionSourceID = sourceID
			isShowingSectionEditSheet = true
		}

		func showAddBankAccountSheet(sourceID: String = "addButton") {
			guard let profileID = selectedProfile?.profile.id else { return }
			showSectionEditSheet(
				for: .bankAccountDraft(bankAccountViewModel.createDraft(for: profileID)),
				sourceID: sourceID
			)
		}

		func showAddInvestmentAccountSheet(sourceID: String = "addButton") {
			guard let profileID = selectedProfile?.profile.id else { return }
			showSectionEditSheet(
				for: .investmentAccountDraft(investmentAccountViewModel.createDraft(for: profileID)),
				sourceID: sourceID
			)
		}

		func showAddHealthSavingsAccountSheet(sourceID: String = "addButton") {
			guard let profileID = selectedProfile?.profile.id else { return }
			showSectionEditSheet(
				for: .healthSavingsAccountDraft(
					healthSavingsAccountViewModel.createDraft(for: profileID)
				),
				sourceID: sourceID
			)
		}

		func showAddInsurancePolicySheet(sourceID: String = "addButton") {
			guard let profileID = selectedProfile?.profile.id else { return }
			showSectionEditSheet(
				for: .insurancePolicyDraft(
					InsurancePolicy(id: UUID(), profileID: profileID, type: .health)
				),
				sourceID: sourceID
			)
		}

		func showAddOtherSheet(sourceID: String = "addButton") {
			guard let profileID = selectedProfile?.profile.id else { return }
			showSectionEditSheet(
				for: .otherDraft(
					otherViewModel.createCategoryDraft(for: .money, profileID: profileID)
				),
				sourceID: sourceID
			)
		}
	}
}
