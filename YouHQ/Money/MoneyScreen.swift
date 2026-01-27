//
//  MoneyScreen.swift
//  YouHQ
//
//  Created by Ryan Token on 12/29/25.
//

import SQLiteData
import SwiftUI

struct MoneyScreen: View {
	@State private var vm = ViewModel()
	@AppStorage("hideAccountNumbers") private var hideAccountNumbers = false

	var body: some View {
		List {
			Group {
				SharingStatus(for: vm.selectedProfile)

				if hasNoAccounts {
					NoAccountsView(vm: vm)
				} else {
					Toggle(isOn: $hideAccountNumbers) {
						Text("Hide Account Numbers")
							.foregroundStyle(.secondary)
							.font(.headline)
					}
					#if os(macOS)
						.padding(.vertical, 4)
					#endif

					MoneyInfo(vm: vm, hideAccountNumbers: hideAccountNumbers)

					AddMoreButton(vm: vm)
				}
			}
			.listRowSeparator(.hidden)
			.listRowBackground(Color.clear)
		}
		.animation(.default, value: vm.bankAccountViewModel.bankAccounts.count)
		.animation(.default, value: vm.investmentAccountViewModel.investmentAccounts.count)
		.animation(.default, value: vm.healthSavingsAccountViewModel.healthSavingsAccounts.count)
		.animation(.default, value: vm.insuranceViewModel.insurancePolicies.count)
		.animation(.default, value: vm.otherViewModel.others.count)
		.navigationTitle("Money")
		.navigationTitle("Career")
		#if !os(macOS)
			.navigationBarTitleDisplayMode(.inline)
		#endif
		.toolbar { Toolbar(vm: vm) }
		.contentMargins(.top, 0)
		.scrollContentBackground(.hidden)
		.task {
			await vm.loadProfiles()
			await vm.loadMoneyData()
		}
		.onChange(of: vm.profiles.count) {
			Task { await vm.loadMoneyData() }
		}
		.sheet(isPresented: $vm.isShowingSectionEditSheet) {
			if let sectionToEdit = vm.sectionToEdit {
				SectionEditSheet(
					section: sectionToEdit,
					draftInsurancePolicy: $vm.insuranceViewModel.draftInsurancePolicy,
					draftOther: $vm.otherViewModel.draftOther,
					draftBankAccount: $vm.bankAccountViewModel.draftBankAccount,
					draftInvestmentAccount: $vm.investmentAccountViewModel.draftInvestmentAccount,
					draftHealthSavingsAccount: $vm.healthSavingsAccountViewModel.draftHealthSavingsAccount
				)
			}
		}
		#if !os(visionOS)
			.scrollDismissesKeyboard(.immediately)
		#endif
	}

	private var hasNoAccounts: Bool {
		vm.bankAccountViewModel.bankAccounts.isEmpty
			&& vm.investmentAccountViewModel.investmentAccounts.isEmpty
			&& vm.healthSavingsAccountViewModel.healthSavingsAccounts.isEmpty
			&& vm.insuranceViewModel.insurancePolicies.isEmpty
			&& vm.otherViewModel.others.isEmpty
	}
}

#Preview {
	let _ = prepareDependencies { // swiftlint:disable:this redundant_discardable_let
		try? $0.bootstrapDatabase()
		try? $0.defaultDatabase.seed()
	}

	NavigationStack {
		MoneyScreen()
	}
}
