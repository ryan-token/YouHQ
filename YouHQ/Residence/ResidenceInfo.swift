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
				}
			) {
				if residence.address != residence.shortAddress {
					InfoRow("Address:", value: residence.address)
				}

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
			}

			ForEach(vm.utilities) { utility in
				UtilitySection(for: utility)
			}

			InfoSection(
				"Notes",
				backgroundColor: $vm.backgroundColor,
				onColorChange: { newColor in
					vm.updateResidenceBackgroundColor(newColor)
				}
			) {
				TextEditor(text: $vm.residenceNotes)
					.frame(minHeight: 100)
					.foregroundStyle(.white)
			}
		}
	}
}

#Preview {
	ResidenceInfo(vm: ResidenceScreen.ViewModel())
}
