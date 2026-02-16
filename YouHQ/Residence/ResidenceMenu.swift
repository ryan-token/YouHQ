//
//  ResidenceMenu.swift
//  YouHQ
//
//  Created by Ryan Token on 1/11/26.
//

import SwiftUI

struct ResidenceMenu: View {
	@Environment(PaywallManager.self) private var paywallManager

	let vm: ResidenceScreen.ViewModel
	let includeAddResidence: Bool

	init(vm: ResidenceScreen.ViewModel, includeAddResidence: Bool = false) {
		self.vm = vm
		self.includeAddResidence = includeAddResidence
	}

	var body: some View {
		Group {
			if includeAddResidence {
				Button {
					if paywallManager.hasUnlockedPremium || vm.residences.count < Constants.paywallResidencesThreshold {
						vm.showCreateResidenceSheet()
					} else {
						paywallManager.showPaywall()
					}
				} label: {
					Label("Add Residence", systemImage: "house.fill")
				}

				Divider()
			}

			if !vm.residences.isEmpty {
				Button {
					if paywallManager.hasUnlockedPremium || vm.residenceItemsCount < Constants.paywallCoreItemsThreshold {
						vm.showAddUtilitySheet()
					} else {
						paywallManager.showPaywall()
					}
				} label: {
					Label("Add Utility", systemImage: "bolt.fill")
				}

				Button {
					if paywallManager.hasUnlockedPremium || vm.residenceItemsCount < Constants.paywallCoreItemsThreshold {
						vm.showAddInsurancePolicySheet()
					} else {
						paywallManager.showPaywall()
					}
				} label: {
					Label("Add Insurance Policy", systemImage: "shield.fill")
				}

				Button {
					if paywallManager.hasUnlockedPremium || vm.paintColorViewModel.paintColors.count < Constants.paywallPaintColorsThreshold
					{
						vm.showAddPaintColorSheet()
					} else {
						paywallManager.showPaywall()
					}
				} label: {
					Label("Add Paint Color", systemImage: "paintbrush.fill")
				}

				Button {
					if paywallManager.hasUnlockedPremium
						|| vm.maintenanceViewModel.maintenanceItems.count < Constants.paywallMaintenanceItemsThreshold
					{
						vm.showAddMaintenanceItemSheet()
					} else {
						paywallManager.showPaywall()
					}
				} label: {
					Label("Add Maintenance Item", systemImage: "wrench.and.screwdriver.fill")
				}

				Button {
					if paywallManager.hasUnlockedPremium || vm.residenceItemsCount < Constants.paywallCoreItemsThreshold {
						vm.showAddOtherSheet()
					} else {
						paywallManager.showPaywall()
					}
				} label: {
					Label("Add Other", systemImage: "ellipsis.circle.fill")
				}
			}
		}
	}
}
