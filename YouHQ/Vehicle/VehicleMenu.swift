//
//  VehicleMenu.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct VehicleMenu: View {
	let vm: VehicleScreen.ViewModel
	let includeAddVehicle: Bool
	let sourceID: String

	init(vm: VehicleScreen.ViewModel, includeAddVehicle: Bool = false, sourceID: String = "addButton") {
		self.vm = vm
		self.includeAddVehicle = includeAddVehicle
		self.sourceID = sourceID
	}

	var body: some View {
		Group {
			if includeAddVehicle {
				PaywalledMenuButton(
					title: "Add Vehicle",
					systemImage: "car.2.fill",
					currentCount: vm.vehicles.count,
					threshold: Constants.paywallVehiclesThreshold
				) {
					vm.showCreateVehicleSheet(sourceID: sourceID)
				}

				Divider()
			}

			if !vm.vehicles.isEmpty {
				PaywalledMenuButton(
					title: "Add Insurance Policy",
					systemImage: "shield.fill",
					currentCount: vm.vehicleItemsCount,
					threshold: Constants.paywallCoreItemsThreshold
				) {
					vm.showAddInsurancePolicySheet(sourceID: sourceID)
				}

				PaywalledMenuButton(
					title: "Add Paint Color",
					systemImage: "paintbrush.fill",
					currentCount: vm.paintColorViewModel.paintColors.count,
					threshold: Constants.paywallPaintColorsThreshold
				) {
					vm.showAddPaintColorSheet(sourceID: sourceID)
				}

				PaywalledMenuButton(
					title: "Add Maintenance Item",
					systemImage: "wrench.and.screwdriver.fill",
					currentCount: vm.maintenanceViewModel.maintenanceItems.count,
					threshold: Constants.paywallMaintenanceItemsThreshold
				) {
					vm.showAddMaintenanceItemSheet(sourceID: sourceID)
				}

				PaywalledMenuButton(
					title: "Add Other",
					systemImage: "ellipsis.circle.fill",
					currentCount: vm.vehicleItemsCount,
					threshold: Constants.paywallCoreItemsThreshold
				) {
					vm.showAddOtherSheet(sourceID: sourceID)
				}
			}
		}
	}
}
