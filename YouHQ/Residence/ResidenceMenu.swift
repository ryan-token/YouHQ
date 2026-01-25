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

	init(vm: ResidenceScreen.ViewModel, includeAddResidence: Bool = false) {
		self.vm = vm
		self.includeAddResidence = includeAddResidence
	}

	var body: some View {
		Group {
			if includeAddResidence {
				Button {
					vm.showCreateResidenceSheet()
				} label: {
					Label("Add Residence", systemImage: "house.fill")
				}

				Divider()
			}

			if !vm.residences.isEmpty {
				Button {
					vm.showAddUtilitySheet()
				} label: {
					Label("Add Utility", systemImage: "bolt.fill")
				}

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
