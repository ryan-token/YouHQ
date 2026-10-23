//
//  MoneyInfo.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct MoneyInfo: View {
	let vm: MoneyScreen.ViewModel
	let hideAccountNumbers: Bool

	var body: some View {
		ForEach(vm.bankAccountViewModel.bankAccounts) { account in
			BankAccountSection(
				account: account,
				hideAccountNumbers: hideAccountNumbers,
				onColorChange: { newColor in
					vm.bankAccountViewModel.updateBackgroundColor(
						newColor,
						for: account
					)
				},
				onTap: {
					vm.showSectionEditSheet(for: .bankAccount(account), sourceID: account.id.uuidString)
				}
			)
			.editableRow(id: account.id) {
				vm.bankAccountViewModel.delete(account)
			}
		}

		ForEach(vm.investmentAccountViewModel.investmentAccounts) { account in
			InvestmentAccountSection(
				account: account,
				hideAccountNumbers: hideAccountNumbers,
				onColorChange: { newColor in
					vm.investmentAccountViewModel.updateBackgroundColor(
						newColor,
						for: account
					)
				},
				onTap: {
					vm.showSectionEditSheet(for: .investmentAccount(account), sourceID: account.id.uuidString)
				}
			)
			.editableRow(id: account.id) {
				vm.investmentAccountViewModel.delete(account)
			}
		}

		ForEach(vm.healthSavingsAccountViewModel.healthSavingsAccounts) { account in
			HealthSavingsAccountSection(
				account: account,
				hideAccountNumbers: hideAccountNumbers,
				onColorChange: { newColor in
					vm.healthSavingsAccountViewModel.updateBackgroundColor(
						newColor,
						for: account
					)
				},
				onTap: {
					vm.showSectionEditSheet(for: .healthSavingsAccount(account), sourceID: account.id.uuidString)
				}
			)
			.editableRow(id: account.id) {
				vm.healthSavingsAccountViewModel.delete(account)
			}
		}

		ForEach(vm.insuranceViewModel.insurancePolicies) { policy in
			InsuranceSection(
				policy: policy,
				hideCosts: false,
				onColorChange: { newColor in
					vm.insuranceViewModel.updateBackgroundColor(
						newColor,
						for: policy
					)
				},
				onTap: {
					vm.showSectionEditSheet(for: .insurancePolicy(policy), sourceID: policy.id.uuidString)
				}
			)
			.editableRow(id: policy.id) {
				vm.insuranceViewModel.delete(policy)
			}
		}

		ForEach(vm.otherViewModel.others) { other in
			OtherSection(
				other: other,
				hideCosts: false,
				onColorChange: { newColor in
					vm.otherViewModel.updateBackgroundColor(
						newColor,
						for: other
					)
				},
				onTap: {
					vm.showSectionEditSheet(for: .other(other), sourceID: other.id.uuidString)
				}
			)
			.editableRow(id: other.id) {
				vm.otherViewModel.delete(other)
			}
		}
	}
}
