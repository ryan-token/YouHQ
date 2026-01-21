//
//  ResidenceInfo.swift
//  YouHQ
//
//  Created by Ryan Token on 1/2/26.
//

import SwiftUI

struct ResidenceInfo: View {
	@Bindable var vm: ResidenceScreen.ViewModel
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
					vm.sectionToEdit = .residenceInfo(residence)
					vm.isShowingSectionEditSheet = true
				},
				onColorChange: { newColor in
					vm.updateResidenceBackgroundColor(newColor)
				}
			)

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
						vm.sectionToEdit = .utility(utility)
						vm.isShowingSectionEditSheet = true
					}
				)
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

			InfoSection(
				"Notes",
				backgroundColor: vm.backgroundColor,
				onColorChange: { newColor in
					vm.updateResidenceBackgroundColor(newColor)
				}
			) {
				TextEditor(text: $vm.residenceNotes)
					.textEditorOnColor(minHeight: 100)
					.onChange(of: vm.residenceNotes) {
						vm.updateResidenceNotesDebounced()
					}
			}

			if !vm.paintColorViewModel.paintColors.isEmpty {
				PaintColorsNavButton(
					isNavigating: $vm.isNavigatingToPaintColors,
					residenceID: residence.id,
					paintColors: vm.paintColorViewModel.paintColors
				)
			}

			if !vm.maintenanceViewModel.maintenanceItems.isEmpty {
				MaintenanceItemsNavButton(
					isNavigating: $vm.isNavigatingToMaintenanceItems,
					residenceID: residence.id,
					maintenanceItems: vm.maintenanceViewModel.maintenanceItems
				)
			}

			AddMoreButton(vm: vm)
		}
	}
}
