//
//  VehicleInfo.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct VehicleInfo: View {
	@Bindable var vm: VehicleScreen.ViewModel
	let hideCosts: Bool

	var body: some View {
		if let vehicle = vm.selectedVehicle {
			VehicleInfoSection(
				vehicle: vehicle,
				insurancePolicies: vm.insuranceViewModel.insurancePolicies,
				others: vm.otherViewModel.others,
				hideCosts: hideCosts,
				backgroundColor: vm.backgroundColor,
				onTap: { vehicle in
					vm.sectionToEdit = .vehicleInfo(vehicle)
					vm.isShowingSectionEditSheet = true
				},
				onColorChange: { newColor in
					vm.updateVehicleBackgroundColor(newColor)
				}
			)

			ForEach(vm.insuranceViewModel.insurancePolicies) { policy in
				InsuranceSection(
					policy: policy,
					hideCosts: hideCosts,
					onColorChange: { newColor in
						vm.insuranceViewModel.updateBackgroundColor(
							newColor,
							for: policy
						)
					},
					onTap: {
						vm.sectionToEdit = .insurancePolicy(policy)
						vm.isShowingSectionEditSheet = true
					}
				)
				.swipeActions(edge: .trailing, allowsFullSwipe: true) {
					Button(role: .destructive) {
						vm.insuranceViewModel.delete(policy)
					} label: {
						Label("Delete", systemImage: "trash")
					}
				}
			}

			ForEach(vm.otherViewModel.others) { other in
				OtherSection(
					other: other,
					hideCosts: hideCosts,
					onColorChange: { newColor in
						vm.otherViewModel.updateBackgroundColor(
							newColor,
							for: other
						)
					},
					onTap: {
						vm.sectionToEdit = .other(other)
						vm.isShowingSectionEditSheet = true
					}
				)
				.swipeActions(edge: .trailing, allowsFullSwipe: true) {
					Button(role: .destructive) {
						vm.otherViewModel.delete(other)
					} label: {
						Label("Delete", systemImage: "trash")
					}
				}
			}

			if !vm.paintColorViewModel.paintColors.isEmpty {
				PaintColorsNavButton(
					isNavigating: $vm.isNavigatingToPaintColors,
					paintColors: vm.paintColorViewModel.paintColors
				)
			}

			if !vm.maintenanceViewModel.maintenanceItems.isEmpty {
				MaintenanceItemsNavButton(
					isNavigating: $vm.isNavigatingToMaintenanceItems,
					maintenanceItems: vm.maintenanceViewModel.maintenanceItems
				)
			}

			AddMoreButton(vm: vm)
		}
	}
}

#Preview {
	@Previewable @State var vm = VehicleScreen.ViewModel()
	VehicleInfo(vm: vm, hideCosts: false)
}
