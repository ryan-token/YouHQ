//
//  ResidenceInfo.swift
//  YouHQ
//
//  Created by Ryan Token on 1/2/26.
//

import SwiftUI

struct ResidenceInfo: View {
	@Bindable var vm: ResidenceScreen.ViewModel
	@Environment(\.sheetNamespace) private var namespace
	let hideCosts: Bool

	var body: some View {
		if let residence = vm.selectedResidence {
			ResidenceInfoSection(
				residence: residence,
				utilities: vm.utilityViewModel.utilities,
				insurancePolicies: vm.insuranceViewModel.insurancePolicies,
				others: vm.otherViewModel.others,
				hideCosts: hideCosts,
				backgroundColor: vm.backgroundColor,
				onTap: { residence in
					vm.sheetTransitionSourceID = residence.id.uuidString
					vm.sectionToEdit = .residenceInfo(residence)
					vm.isShowingSectionEditSheet = true
				},
				onColorChange: { newColor in
					vm.updateResidenceBackgroundColor(newColor)
				}
			)
			.matchedTransitionSource(id: residence.id.uuidString, in: namespace)

			ForEach(vm.utilityViewModel.utilities) { utility in
				UtilitySection(
					utility: utility,
					hideCosts: hideCosts,
					onColorChange: { newColor in
						vm.utilityViewModel.updateBackgroundColor(
							newColor,
							for: utility
						)
					},
					onTap: {
						vm.sheetTransitionSourceID = utility.id.uuidString
						vm.sectionToEdit = .utility(utility)
						vm.isShowingSectionEditSheet = true
					}
				)
				.matchedTransitionSource(id: utility.id.uuidString, in: namespace)
				.swipeActions(edge: .trailing, allowsFullSwipe: true) {
					Button(role: .destructive) {
						vm.utilityViewModel.delete(utility)
					} label: {
						Label("Delete", systemImage: "trash")
					}
				}
			}

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
						vm.sheetTransitionSourceID = policy.id.uuidString
						vm.sectionToEdit = .insurancePolicy(policy)
						vm.isShowingSectionEditSheet = true
					}
				)
				.matchedTransitionSource(id: policy.id.uuidString, in: namespace)
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
						vm.sheetTransitionSourceID = other.id.uuidString
						vm.sectionToEdit = .other(other)
						vm.isShowingSectionEditSheet = true
					}
				)
				.matchedTransitionSource(id: other.id.uuidString, in: namespace)
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
