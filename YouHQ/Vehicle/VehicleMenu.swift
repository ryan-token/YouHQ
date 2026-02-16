//
//  VehicleMenu.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct VehicleMenu: View {
	@Environment(PaywallManager.self) private var paywallManager

	let vm: VehicleScreen.ViewModel
	let includeAddVehicle: Bool

	init(vm: VehicleScreen.ViewModel, includeAddVehicle: Bool = false) {
		self.vm = vm
		self.includeAddVehicle = includeAddVehicle
	}

	var body: some View {
		Group {
			if includeAddVehicle {
				Button {
					if paywallManager.hasUnlockedPremium || vm.vehicles.count < Constants.paywallVehiclesThreshold {
						vm.showCreateVehicleSheet()
					} else {
						paywallManager.showPaywall()
					}
				} label: {
					Label("Add Vehicle", systemImage: "car.2.fill")
				}

				Divider()
			}

			if !vm.vehicles.isEmpty {
				Button {
					if paywallManager.hasUnlockedPremium || vm.vehicleItemsCount < Constants.paywallCoreItemsThreshold {
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
					if paywallManager.hasUnlockedPremium || vm.vehicleItemsCount < Constants.paywallCoreItemsThreshold {
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
