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
		@Dependency(\.defaultSyncEngine) var syncEngine
		@Bindable var vm: VehicleScreen.ViewModel
		let namespace: Namespace.ID

		var body: some ToolbarContent {
			if vm.vehicles.count > 1 {
				ToolbarTitleMenu {
					Picker(
						"Choose Vehicle",
						selection: Binding(
							get: { vm.selectedVehicle?.id },
							set: { newID in
								if let vehicle = vm.vehicles.first(where: { $0.id == newID }) {
									vm.selectedVehicle = vehicle
								}
							}
						)
					) {
						ForEach(vm.vehicles) { vehicle in
							HQText(vehicle.displayName)
								.tag(vehicle.id)
						}
					}
				}
			}

			if vm.vehicles.isEmpty && syncEngine.isSynchronizing {
				ToolbarItem(placement: .primaryAction) {
					ProgressView()
				}
			} else {
				ToolbarItem(placement: .primaryAction) {
					Menu {
						VehicleMenu(vm: vm, includeAddVehicle: true)
					} label: {
						Label("Add", systemImage: "plus")
					}
					.matchedTransitionSource(id: "addButton", in: namespace)
				}
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
