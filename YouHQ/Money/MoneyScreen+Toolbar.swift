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
		@Bindable var vm: MoneyScreen.ViewModel
		let namespace: Namespace.ID

		private var hasNoMoneyItems: Bool {
			vm.bankAccountViewModel.bankAccounts.isEmpty
				&& vm.investmentAccountViewModel.investmentAccounts.isEmpty
				&& vm.healthSavingsAccountViewModel.healthSavingsAccounts.isEmpty
				&& vm.insuranceViewModel.insurancePolicies.isEmpty
				&& vm.otherViewModel.others.isEmpty
		}

		var body: some ToolbarContent {
			AddMenuToolbarItem(showProgressViewIfSyncing: hasNoMoneyItems, namespace: namespace) {
				MoneyMenu(vm: vm)
			}
		}
	}
}
