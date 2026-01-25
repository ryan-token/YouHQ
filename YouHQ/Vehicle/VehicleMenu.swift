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

	init(vm: VehicleScreen.ViewModel, includeAddVehicle: Bool = false) {
		self.vm = vm
		self.includeAddVehicle = includeAddVehicle
	}

	var body: some View {
		Group {
			if includeAddVehicle {
				Button {
					vm.showCreateVehicleSheet()
				} label: {
					Label("Add Vehicle", systemImage: "car.2.fill")
				}

				Divider()
			}

			if !vm.vehicles.isEmpty {
				Button {
					vm.showAddInsurancePolicySheet()
				} label: {
					Label("Add Insurance Policy", systemImage: "shield.fill")
				}

				Button {
					vm.showAddMaintenanceItemSheet()
				} label: {
					Label("Add Maintenance Item", systemImage: "wrench.and.screwdriver.fill")
				}

				Button {
					vm.showAddPaintColorSheet()
				} label: {
					Label("Add Paint Color", systemImage: "paintbrush.fill")
				}

				Button {
					vm.showAddOtherSheet()
				} label: {
					Label("Add Other", systemImage: "ellipsis.circle.fill")
				}
			}
		}
	}
}
