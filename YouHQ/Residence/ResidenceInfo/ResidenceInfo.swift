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
			Section("Info") {
				if residence.address != residence.shortAddress {
					HStack(alignment: .top) {
						Text("Full address:")
						SecondaryText(residence.address)
							.textSelection(.enabled)
					}
				}

				if let moveInDate = residence.moveInDate {
					HStack {
						Text("Move in date:")
						SecondaryText(
							moveInDate.formatted(date: .abbreviated, time: .omitted)
						)
						.textSelection(.enabled)
					}
				}

				if let moveOutDate = residence.moveOutDate {
					HStack {
						Text("Move out date:")
						SecondaryText(
							moveOutDate.formatted(
								date: .abbreviated,
								time: .omitted
							)
						)
						.textSelection(.enabled)
					}
				}

				if let monthlyCost = residence.monthlyCost {
					HStack {
						Text("Monthly cost:")
						SecondaryText("\(monthlyCost.asCost)")
							.textSelection(.enabled)
					}
				}
			}

			ForEach(vm.utilities) { utility in
				UtilitySection(for: utility)
			}

			Section("Notes") {
				TextEditor(text: $vm.residenceNotes)
					.frame(minHeight: 100)
			}
			.listSectionSpacing(.compact)
			.listRowSeparator(.hidden)
			.padding(.leading, 12)
		}
	}
}

#Preview {
	ResidenceInfo(vm: ResidenceScreen.ViewModel())
}
