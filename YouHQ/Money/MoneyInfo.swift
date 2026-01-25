//
//  MoneyInfo.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct MoneyInfo: View {
	@Bindable var vm: MoneyScreen.ViewModel
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
					vm.sectionToEdit = .bankAccount(account)
					vm.isShowingSectionEditSheet = true
				}
			)
			.swipeActions(edge: .trailing, allowsFullSwipe: true) {
				Button(role: .destructive) {
					vm.bankAccountViewModel.delete(account)
				} label: {
					Label("Delete", systemImage: "trash")
				}
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
					vm.sectionToEdit = .investmentAccount(account)
					vm.isShowingSectionEditSheet = true
				}
			)
			.swipeActions(edge: .trailing, allowsFullSwipe: true) {
				Button(role: .destructive) {
					vm.investmentAccountViewModel.delete(account)
				} label: {
					Label("Delete", systemImage: "trash")
				}
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
					vm.sectionToEdit = .healthSavingsAccount(account)
					vm.isShowingSectionEditSheet = true
				}
			)
			.swipeActions(edge: .trailing, allowsFullSwipe: true) {
				Button(role: .destructive) {
					vm.healthSavingsAccountViewModel.delete(account)
				} label: {
					Label("Delete", systemImage: "trash")
				}
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
					vm.sectionToEdit = .insurancePolicy(policy)
					vm.isShowingSectionEditSheet = true
				}
			)
			.swipeActions(edge: .trailing, allowsFullSwipe: true) {
				Button(role: .destructive) {
					vm.insuranceViewModel.delete(policy)
				} label: {
					Label("Delete", systemImage: "trash")
				}
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
					vm.sectionToEdit = .other(other)
					vm.isShowingSectionEditSheet = true
				}
			)
			.swipeActions(edge: .trailing, allowsFullSwipe: true) {
				Button(role: .destructive) {
					vm.otherViewModel.delete(other)
				} label: {
					Label("Delete", systemImage: "trash")
				}
			}
		}
	}
}
