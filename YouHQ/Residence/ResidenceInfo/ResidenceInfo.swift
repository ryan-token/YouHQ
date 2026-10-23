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
					vm.showSectionEditSheet(for: .residenceInfo(residence), sourceID: residence.id.uuidString)
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
						vm.showSectionEditSheet(for: .utility(utility), sourceID: utility.id.uuidString)
					}
				)
				.matchedTransitionSource(id: utility.id.uuidString, in: namespace)
				.swipeActions(edge: .trailing, allowsFullSwipe: true) {
					Button("Delete", systemImage: "trash", role: .destructive) {
						vm.utilityViewModel.delete(utility)
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
						vm.showSectionEditSheet(for: .insurancePolicy(policy), sourceID: policy.id.uuidString)
					}
				)
				.matchedTransitionSource(id: policy.id.uuidString, in: namespace)
				.swipeActions(edge: .trailing, allowsFullSwipe: true) {
					Button("Delete", systemImage: "trash", role: .destructive) {
						vm.insuranceViewModel.delete(policy)
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
						vm.showSectionEditSheet(for: .other(other), sourceID: other.id.uuidString)
					}
				)
				.matchedTransitionSource(id: other.id.uuidString, in: namespace)
				.swipeActions(edge: .trailing, allowsFullSwipe: true) {
					Button("Delete", systemImage: "trash", role: .destructive) {
						vm.otherViewModel.delete(other)
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
