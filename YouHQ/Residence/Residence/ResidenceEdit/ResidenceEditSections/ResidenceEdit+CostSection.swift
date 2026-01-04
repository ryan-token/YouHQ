//
//  ResidenceEdit+CostSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/3/26.
//

import SwiftUI

extension ResidenceEdit {
	struct CostSection: View {
		@Bindable var vm: ResidenceEdit.ViewModel

		var body: some View {
			Section("Cost") {
				Picker("Cost Type", selection: $vm.costType) {
					ForEach(CostType.allCases, id: \.self) { type in
						Text(type.rawValue).tag(type)
					}
				}

				if vm.costType != .owned {
					TextField(
						"Monthly Cost (Optional)",
						value: Binding(
							get: { vm.monthlyCost ?? 0 },
							set: { vm.monthlyCost = $0 }
						),
						format: .currency(code: "USD")
					)
					.keyboardType(.decimalPad)
				}
			}
		}
	}
}

#Preview {
	Form {
		ResidenceEdit.CostSection(
			vm: ResidenceEdit.ViewModel(
				residence: nil,
				profileID: UUID()
			)
		)
	}
}
