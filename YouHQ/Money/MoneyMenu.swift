//
//  MoneyMenu.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct MoneyMenu: View {
	let vm: MoneyScreen.ViewModel
	let sourceID: String

	init(vm: MoneyScreen.ViewModel, sourceID: String = "addButton") {
		self.vm = vm
		self.sourceID = sourceID
	}

	var body: some View {
		PaywalledButton(
			title: "Add Bank Account",
			systemImage: "building.columns.fill",
			currentCount: vm.moneyItemsCount,
			threshold: Constants.paywallCoreItemsThreshold
		) {
			vm.showAddBankAccountSheet(sourceID: sourceID)
		}

		PaywalledButton(
			title: "Add Investment Account",
			systemImage: "chart.line.uptrend.xyaxis",
			currentCount: vm.moneyItemsCount,
			threshold: Constants.paywallCoreItemsThreshold
		) {
			vm.showAddInvestmentAccountSheet(sourceID: sourceID)
		}

		PaywalledButton(
			title: "Add HSA/FSA",
			systemImage: "cross.case.fill",
			currentCount: vm.moneyItemsCount,
			threshold: Constants.paywallCoreItemsThreshold
		) {
			vm.showAddHealthSavingsAccountSheet(sourceID: sourceID)
		}

		PaywalledButton(
			title: "Add Insurance Policy",
			systemImage: "shield.fill",
			currentCount: vm.moneyItemsCount,
			threshold: Constants.paywallCoreItemsThreshold
		) {
			vm.showAddInsurancePolicySheet(sourceID: sourceID)
		}

		PaywalledButton(
			title: "Add Other",
			systemImage: "ellipsis.circle.fill",
			currentCount: vm.moneyItemsCount,
			threshold: Constants.paywallCoreItemsThreshold
		) {
			vm.showAddOtherSheet(sourceID: sourceID)
		}
	}
}
