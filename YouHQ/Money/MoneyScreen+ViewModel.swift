//
//  MoneyScreen+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

extension MoneyScreen {
	@Observable
	class ViewModel: ProfileSelection {
		@ObservationIgnored
		@FetchAll(ProfileShare.none, animation: .default) var profiles

		@ObservationIgnored
		@AppStorage(.selectedProfileIDKey) var selectedProfileIDString: String = ""

		// Child view models for entity-specific operations
		var bankAccountViewModel = BankAccountViewModel()
		var investmentAccountViewModel = InvestmentAccountViewModel()
		var healthSavingsAccountViewModel = HealthSavingsAccountViewModel()
		var insuranceViewModel = InsurancePolicyViewModel()
		var otherViewModel = OtherItemViewModel()

		init() {}

		var selectedProfile: ProfileShare? {
			getSelectedProfile()
		}

		var isShowingSectionEditSheet = false
		var sectionToEdit: EditableSection?

		// MARK: PROFILE FUNCTIONS

		func loadProfiles() async {
			_ = await withErrorReporting {
				try await $profiles.load(
					Profile
						.group(by: \.id)
						.leftJoin(SyncMetadata.all) {
							$0.syncMetadataID.eq($1.id)
						}
						.select {
							ProfileShare.Columns(
								profile: $0,
								isShared: $1.isShared.ifnull(false)
							)
						},
					animation: .default
				)
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

		func showAddBankAccountSheet() {
			guard let profileID = selectedProfile?.profile.id else { return }
			bankAccountViewModel.draftBankAccount =
				bankAccountViewModel.createDraft(for: profileID)
			sectionToEdit = .bankAccountDraft
			isShowingSectionEditSheet = true
		}

		func showAddInvestmentAccountSheet() {
			guard let profileID = selectedProfile?.profile.id else { return }
			investmentAccountViewModel.draftInvestmentAccount =
				investmentAccountViewModel.createDraft(for: profileID)
			sectionToEdit = .investmentAccountDraft
			isShowingSectionEditSheet = true
		}

		func showAddHealthSavingsAccountSheet() {
			guard let profileID = selectedProfile?.profile.id else { return }
			healthSavingsAccountViewModel.draftHealthSavingsAccount =
				healthSavingsAccountViewModel.createDraft(for: profileID)
			sectionToEdit = .healthSavingsAccountDraft
			isShowingSectionEditSheet = true
		}

		func showAddInsurancePolicySheet() {
			guard let profileID = selectedProfile?.profile.id else { return }
			insuranceViewModel.draftInsurancePolicy =
				InsurancePolicy(
					id: UUID(),
					profileID: profileID,
					type: .health
				)
			sectionToEdit = .insurancePolicyDraft
			isShowingSectionEditSheet = true
		}

		func showAddOtherSheet() {
			guard let profileID = selectedProfile?.profile.id else { return }
			otherViewModel.draftOther =
				otherViewModel.createCategoryDraft(for: .money, profileID: profileID)
			sectionToEdit = .otherDraft
			isShowingSectionEditSheet = true
		}
	}
}
