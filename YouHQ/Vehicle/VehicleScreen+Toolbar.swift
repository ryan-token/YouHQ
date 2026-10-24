//
//  VehicleScreen+Toolbar.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

extension VehicleScreen {
	struct Toolbar: ToolbarContent {
		@Bindable var vm: VehicleScreen.ViewModel
		let namespace: Namespace.ID

		var body: some ToolbarContent {
			if vm.vehicles.count > 1 {
				ToolbarTitleMenu {
					Picker("Choose Vehicle", selection: $vm.pickerSelectedVehicleID) {
						ForEach(vm.vehicles) { vehicle in
							HQText(vehicle.displayName)
								.tag(vehicle.id)
						}
					}
				}
			}

			AddMenuToolbarItem(showProgressViewIfSyncing: vm.vehicles.isEmpty, namespace: namespace) {
				VehicleMenu(vm: vm, includeAddVehicle: true)
			}
		}
	}
}

#Preview {
	struct PreviewWrapper: View {
		@Namespace private var namespace
		var body: some View {
			Form { HQText("VehicleScreen Toolbar") }
				.toolbar { VehicleScreen.Toolbar(vm: VehicleScreen.ViewModel(), namespace: namespace) }
		}
	}
	return PreviewWrapper()
}
