//
//  CareerMenu.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct CareerMenu: View {
	@Environment(PaywallManager.self) private var paywallManager

	let vm: CareerScreen.ViewModel

	var body: some View {
		Button {
			if paywallManager.hasUnlockedPremium || vm.careerItemsCount < Constants.paywallCoreItemsThreshold {
				vm.showAddJobSheet()
			} else {
				paywallManager.isShowingPaywallSheet = true
			}
		} label: {
			Label("Add Job", systemImage: "briefcase.fill")
		}

		Button {
			if paywallManager.hasUnlockedPremium || vm.careerItemsCount < Constants.paywallCoreItemsThreshold {
				vm.showAddOtherSheet()
			} else {
				paywallManager.isShowingPaywallSheet = true
			}
		} label: {
			Label("Add Other", systemImage: "ellipsis.circle.fill")
		}
	}
}
