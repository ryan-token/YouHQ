//
//  UtilitySection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/2/26.
//

import SwiftUI

struct UtilitySection: View {
	@State private var vm: ViewModel
	let onTap: (() -> Void)?

	init(for utility: Utility, onTap: (() -> Void)? = nil) {
		_vm = State(wrappedValue: ViewModel(utility: utility))
		self.onTap = onTap
	}

	var body: some View {
		if let utility = vm.utility {
			InfoSection(
				vm.utilityTitle,
				backgroundColor: $vm.backgroundColor,
				onColorChange: { newColor in
					vm.updateUtilityBackgroundColor(newColor)
				},
				onTap: onTap
			) {
				if utility.provider.isNotEmpty {
					Text(utility.provider)
						.sectionTitle()
				}

				if utility.accountNumber.isNotEmpty {
					InfoRow("Account number:", value: utility.accountNumber)
				}

				if let appxMonthlyCost = utility.approximateMonthlyCost {
					InfoRow("Monthly cost:", value: "\(appxMonthlyCost.asCost)")
				}

				if utility.url.isNotEmpty {
					LinkRow("Website:", url: utility.url)
				}

				if utility.notes.isNotEmpty {
					VStack(alignment: .leading, spacing: 4) {
						Text("Notes:")
							.font(.headline)
							.foregroundStyle(.white)
						Text(utility.notes)
							.foregroundStyle(.white)
					}
				}
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
