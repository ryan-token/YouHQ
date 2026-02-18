//
//  MoneyMenu.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct MoneyMenu: View {
	@Environment(PaywallManager.self) private var paywallManager

	let vm: MoneyScreen.ViewModel
	let sourceID: String

	init(vm: MoneyScreen.ViewModel, sourceID: String = "addButton") {
		self.vm = vm
		self.sourceID = sourceID
	}

	var body: some View {
		Button {
			if paywallManager.hasUnlockedPremium || vm.moneyItemsCount < Constants.paywallCoreItemsThreshold {
				vm.showAddBankAccountSheet(sourceID: sourceID)
			} else {
				paywallManager.showPaywall()
			}
		} label: {
			Label("Add Bank Account", systemImage: "building.columns.fill")
		}

		Button {
			if paywallManager.hasUnlockedPremium || vm.moneyItemsCount < Constants.paywallCoreItemsThreshold {
				vm.showAddInvestmentAccountSheet(sourceID: sourceID)
			} else {
				paywallManager.showPaywall()
			}
		} label: {
			Label("Add Investment Account", systemImage: "chart.line.uptrend.xyaxis")
		}

		Button {
			if paywallManager.hasUnlockedPremium || vm.moneyItemsCount < Constants.paywallCoreItemsThreshold {
				vm.showAddHealthSavingsAccountSheet(sourceID: sourceID)
			} else {
				paywallManager.showPaywall()
			}
		} label: {
			Label("Add HSA/FSA", systemImage: "cross.case.fill")
		}

		Button {
			if paywallManager.hasUnlockedPremium || vm.moneyItemsCount < Constants.paywallCoreItemsThreshold {
				vm.showAddInsurancePolicySheet(sourceID: sourceID)
			} else {
				paywallManager.showPaywall()
			}
		} label: {
			Label("Add Insurance Policy", systemImage: "shield.fill")
		}

		Button {
			if paywallManager.hasUnlockedPremium || vm.moneyItemsCount < Constants.paywallCoreItemsThreshold {
				vm.showAddOtherSheet(sourceID: sourceID)
			} else {
				paywallManager.showPaywall()
			}
		} label: {
			Label("Add Other", systemImage: "ellipsis.circle.fill")
		}
	}
}
