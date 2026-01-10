//
//  UtilitySection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/2/26.
//

import SwiftUI

struct UtilitySection: View {
	@State private var vm: ViewModel

	init(for utility: Utility) {
		_vm = State(wrappedValue: ViewModel(utility: utility))
	}

	var body: some View {
		if let utility = vm.utility {
			InfoSection(
				vm.utilityTitle,
				backgroundColor: $vm.backgroundColor,
				onColorChange: { newColor in
					vm.updateUtilityBackgroundColor(newColor)
				}
			) {
				if utility.provider.isNotEmpty {
					Text(utility.provider)
						.font(.title2)
						.foregroundStyle(.white)
						.opacity(0.8)
				}

				if utility.accountNumber.isNotEmpty {
					InfoRow("Account number:", value: utility.accountNumber)
				}

				if let appxMonthlyCost = utility.approximateMonthlyCost {
					InfoRow("Monthly cost:", value: "\(appxMonthlyCost.asCost)")
				}

				UtilityNotes(notes: $vm.utilityNotes)
			}
		} else {
			Color.clear
				.task { await vm.loadUtilityData() }
		}
	}
}

#Preview {
	UtilitySection(for: Utility.sampleData)
}
