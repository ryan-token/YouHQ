//
//  ResidenceMenu.swift
//  YouHQ
//
//  Created by Ryan Token on 1/11/26.
//

import SwiftUI

struct ResidenceMenu: View {
	let vm: ResidenceScreen.ViewModel
	let includeAddResidence: Bool
	let sourceID: String

	init(vm: ResidenceScreen.ViewModel, includeAddResidence: Bool = false, sourceID: String = "addButton") {
		self.vm = vm
		self.includeAddResidence = includeAddResidence
		self.sourceID = sourceID
	}

	var body: some View {
		Group {
			if includeAddResidence {
				PaywalledButton(
					title: "Add Residence",
					systemImage: "house.fill",
					currentCount: vm.residences.count,
					threshold: Constants.paywallResidencesThreshold
				) {
					vm.showCreateResidenceSheet()
				}

				Divider()
			}

			if !vm.residences.isEmpty {
				PaywalledButton(
					title: "Add Utility",
					systemImage: "bolt.fill",
					currentCount: vm.residenceItemsCount,
					threshold: Constants.paywallCoreItemsThreshold
				) {
					vm.showAddUtilitySheet(sourceID: sourceID)
				}

				PaywalledButton(
					title: "Add Insurance Policy",
					systemImage: "shield.fill",
					currentCount: vm.residenceItemsCount,
					threshold: Constants.paywallCoreItemsThreshold
				) {
					vm.showAddInsurancePolicySheet(sourceID: sourceID)
				}

				PaywalledButton(
					title: "Add Paint Color",
					systemImage: "paintbrush.fill",
					currentCount: vm.paintColorViewModel.paintColors.count,
					threshold: Constants.paywallPaintColorsThreshold
				) {
					vm.showAddPaintColorSheet(sourceID: sourceID)
				}

				PaywalledButton(
					title: "Add Maintenance Item",
					systemImage: "wrench.and.screwdriver.fill",
					currentCount: vm.maintenanceViewModel.maintenanceItems.count,
					threshold: Constants.paywallMaintenanceItemsThreshold
				) {
					vm.showAddMaintenanceItemSheet(sourceID: sourceID)
				}

				PaywalledButton(
					title: "Add Other",
					systemImage: "ellipsis.circle.fill",
					currentCount: vm.residenceItemsCount,
					threshold: Constants.paywallCoreItemsThreshold
				) {
					vm.showAddOtherSheet(sourceID: sourceID)
				}
			}
		}
	}
}
