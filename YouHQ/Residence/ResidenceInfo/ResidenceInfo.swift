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
				for: residence,
				hideCosts: hideCosts,
				onTap: { residence in
					vm.sectionToEdit = .residenceInfo(residence)
					vm.isShowingSectionEditSheet = true
				}
			)
			.id(residence.id)

			ForEach(vm.utilities) { utility in
				UtilitySection(
					for: utility,
					hideCosts: hideCosts,
					onTap: {
						vm.sectionToEdit = .utility(utility, isNew: false)
						vm.isShowingSectionEditSheet = true
					}
				)
				.swipeActions(edge: .trailing, allowsFullSwipe: true) {
					Button(role: .destructive) {
						vm.deleteUtility(utility)
					} label: {
						Label("Delete", systemImage: "trash")
					}
				}
			}

			ForEach(vm.insurancePolicies) { policy in
				InsuranceSection(
					for: policy,
					hideCosts: hideCosts,
					onTap: {
						vm.sectionToEdit = .insurancePolicy(
							policy,
							isNew: false
						)
						vm.isShowingSectionEditSheet = true
					}
				)
				.swipeActions(edge: .trailing, allowsFullSwipe: true) {
					Button(role: .destructive) {
						vm.deleteInsurancePolicy(policy)
					} label: {
						Label("Delete", systemImage: "trash")
					}
				}
			}

			if !vm.maintenanceItems.isEmpty {
				MaintenanceItemsNavigationLink(
					residenceID: residence.id,
					maintenanceItems: vm.maintenanceItems
				)
			}

			ForEach(vm.others) { other in
				OtherSection(
					for: other,
					hideCosts: hideCosts,
					onTap: {
						vm.sectionToEdit = .other(other, isNew: false)
						vm.isShowingSectionEditSheet = true
					}
				)
				.swipeActions(edge: .trailing, allowsFullSwipe: true) {
					Button(role: .destructive) {
						vm.deleteOther(other)
					} label: {
						Label("Delete", systemImage: "trash")
					}
				}
			}

			InfoSection(
				"Notes",
				backgroundColor: $vm.backgroundColor,
				onColorChange: { newColor in
					vm.updateResidenceBackgroundColor(newColor)
				}
			) {
				TextEditor(text: $vm.residenceNotes)
					.textEditorOnColor(minHeight: 100)
			}

			AddMoreButton(vm: vm)
		}
	}
}
