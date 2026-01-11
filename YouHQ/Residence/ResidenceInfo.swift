//
//  ResidenceInfo.swift
//  YouHQ
//
//  Created by Ryan Token on 1/2/26.
//

import SwiftUI

struct ResidenceInfo: View {
	@Bindable var vm: ResidenceScreen.ViewModel

	var body: some View {
		if let residence = vm.selectedResidence {
			InfoSection(
				"Info",
				backgroundColor: $vm.backgroundColor,
				onColorChange: { newColor in
					vm.updateResidenceBackgroundColor(newColor)
				},
				onTap: {
					vm.sectionToEdit = .residenceInfo(residence)
					vm.isShowingSectionEditSheet = true
				}
			) {
				Text(residence.address)
					.sectionTitle()

				if let moveInDate = residence.moveInDate {
					InfoRow(
						"Move in date:",
						value: moveInDate.formatted(
							date: .abbreviated,
							time: .omitted
						)
					)
				}

				if let moveOutDate = residence.moveOutDate {
					InfoRow(
						"Move out date:",
						value: moveOutDate.formatted(
							date: .abbreviated,
							time: .omitted
						)
					)
				}

				if let monthlyCost = residence.monthlyCost {
					InfoRow("Monthly cost:", value: "\(monthlyCost.asCost)")
				}

				if residence.url.isNotEmpty {
					LinkRow("Website:", url: residence.url)
				}
			}

			ForEach(vm.utilities) { utility in
				UtilitySection(
					for: utility,
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
