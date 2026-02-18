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
	let sourceID: String

	init(vm: CareerScreen.ViewModel, sourceID: String = "addButton") {
		self.vm = vm
		self.sourceID = sourceID
	}

	var body: some View {
		Button {
			if paywallManager.hasUnlockedPremium || vm.careerItemsCount < Constants.paywallCoreItemsThreshold {
				vm.showAddJobSheet(sourceID: sourceID)
			} else {
				paywallManager.showPaywall()
			}
		} label: {
			Label("Add Job", systemImage: "briefcase.fill")
		}

		Button {
			if paywallManager.hasUnlockedPremium || vm.careerItemsCount < Constants.paywallCoreItemsThreshold {
				vm.showAddOtherSheet(sourceID: sourceID)
			} else {
				paywallManager.showPaywall()
			}
		} label: {
			Label("Add Other", systemImage: "ellipsis.circle.fill")
		}
	}
}
