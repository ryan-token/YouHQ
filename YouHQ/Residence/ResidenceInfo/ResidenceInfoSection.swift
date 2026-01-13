//
//  ResidenceInfoSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/11/26.
//

import SQLiteData
import SwiftUI

struct ResidenceInfoSection: View {
	@State private var vm: ViewModel
	let hideCosts: Bool
	let onTap: ((Residence) -> Void)?

	init(
		for residence: Residence,
		hideCosts: Bool = false,
		onTap: ((Residence) -> Void)? = nil
	) {
		_vm = State(wrappedValue: ViewModel(residence: residence))
		self.hideCosts = hideCosts
		self.onTap = onTap
	}

	var body: some View {
		if let residence = vm.residence {
			InfoSection(
				"Info",
				backgroundColor: $vm.backgroundColor,
				onColorChange: { newColor in
					vm.updateResidenceBackgroundColor(newColor)
				},
				onTap: {
					onTap?(residence)
				}
			) {
				Text(residence.address)
					.sectionTitle()

				if let moveInDate = residence.moveInDate {
					InfoRow(
						"Move-in date:",
						value: moveInDate.formatted(
							date: .abbreviated,
							time: .omitted
						)
					)
				}

				if let moveOutDate = residence.moveOutDate {
					InfoRow(
						"Move-out date:",
						value: moveOutDate.formatted(
							date: .abbreviated,
							time: .omitted
						)
					)
				}

				if let monthlyCost = residence.monthlyCost,
					residence.costType != .owned {
					InfoRow(
						"Monthly \(residence.costType.rawValue.lowercased()):",
						value: "\(monthlyCost.asCost)",
						blurred: hideCosts
					)
				}

				if vm.totalMonthlyCost > 0 {
					MonthlyTCORow(
						"Monthly TCO:",
						totalCost: vm.totalMonthlyCost,
						residenceCost: residence.monthlyCost,
						residenceCostType: residence.costType,
						utilities: vm.utilities,
						insurancePolicies: vm.insurancePolicies,
						others: vm.others,
						blurred: hideCosts
					)
				}

				if residence.url.isNotEmpty {
					LinkRow("Website:", url: residence.url)
				}
			}
			.onChange(of: vm.residence?.backgroundColor) {
				vm.updateBackgroundColorFromDatabase()
			}
		} else {
			Color.clear
				.task { await vm.loadResidenceData() }
		}
	}
}

#Preview {
	ResidenceInfoSection(for: Residence.sampleData)
}
