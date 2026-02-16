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

	var body: some View {
		Button {
			if paywallManager.hasUnlockedPremium || vm.moneyItemsCount < Constants.paywallCoreItemsThreshold {
				vm.showAddBankAccountSheet()
			} else {
				paywallManager.showPaywall()
			}
		} label: {
			Label("Add Bank Account", systemImage: "building.columns.fill")
		}

		Button {
			if paywallManager.hasUnlockedPremium || vm.moneyItemsCount < Constants.paywallCoreItemsThreshold {
				vm.showAddInvestmentAccountSheet()
			} else {
				paywallManager.showPaywall()
			}
		} label: {
			Label("Add Investment Account", systemImage: "chart.line.uptrend.xyaxis")
		}

		Button {
			if paywallManager.hasUnlockedPremium || vm.moneyItemsCount < Constants.paywallCoreItemsThreshold {
				vm.showAddHealthSavingsAccountSheet()
			} else {
				paywallManager.showPaywall()
			}
		} label: {
			Label("Add HSA/FSA", systemImage: "cross.case.fill")
		}

		Button {
			if paywallManager.hasUnlockedPremium || vm.moneyItemsCount < Constants.paywallCoreItemsThreshold {
				vm.showAddInsurancePolicySheet()
			} else {
				paywallManager.showPaywall()
			}
		} label: {
			Label("Add Insurance Policy", systemImage: "shield.fill")
		}

		Button {
			if paywallManager.hasUnlockedPremium || vm.moneyItemsCount < Constants.paywallCoreItemsThreshold {
				vm.showAddOtherSheet()
			} else {
				paywallManager.showPaywall()
			}
		} label: {
			Label("Add Other", systemImage: "ellipsis.circle.fill")
		}
	}
}
