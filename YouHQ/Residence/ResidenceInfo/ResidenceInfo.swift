//
//  ResidenceInfo.swift
//  YouHQ
//
//  Created by Ryan Token on 1/2/26.
//

import SwiftUI

struct ResidenceInfo: View {
	@State private var vm: ViewModel

	init(residence: Residence) {
		_vm = State(wrappedValue: ViewModel(residence: residence))
	}

	var body: some View {
		Section("Info") {
			if vm.residence.address != vm.residence.shortAddress {
				HStack(alignment: .top) {
					Text("Full address:")
					SecondaryText(vm.residence.address)
						.textSelection(.enabled)
				}
			}

			if let moveInDate = vm.residence.moveInDate {
				HStack {
					Text("Move in date:")
					SecondaryText(
						moveInDate.formatted(date: .abbreviated, time: .omitted)
					)
					.textSelection(.enabled)
				}
			}

			if let moveOutDate = vm.residence.moveOutDate {
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

			if let monthlyCost = vm.residence.monthlyCost {
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
		.task { await vm.onAppear() }
	}
}

#Preview {
	ResidenceInfo(residence: Residence.sampleData)
}
