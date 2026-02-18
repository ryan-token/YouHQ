//
//  MoneyScreen+Toolbar.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

extension MoneyScreen {
	struct Toolbar: ToolbarContent {
		@Dependency(\.defaultSyncEngine) var syncEngine
		@Bindable var vm: MoneyScreen.ViewModel
		let namespace: Namespace.ID

		var body: some ToolbarContent {
			if vm.bankAccountViewModel.bankAccounts.isEmpty
				&& vm.investmentAccountViewModel.investmentAccounts.isEmpty
				&& vm.healthSavingsAccountViewModel.healthSavingsAccounts.isEmpty
				&& vm.insuranceViewModel.insurancePolicies.isEmpty
				&& vm.otherViewModel.others.isEmpty
				&& syncEngine.isSynchronizing
			{
				ToolbarItem(placement: .primaryAction) {
					ProgressView()
				}
			} else {
				ToolbarItem(placement: .primaryAction) {
					Menu {
						MoneyMenu(vm: vm)
					} label: {
						Label("Add", systemImage: "plus")
					}
					.matchedTransitionSource(id: "addButton", in: namespace)
				}
			}
		}
	}
}
