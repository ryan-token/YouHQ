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
			Section(vm.utilityTitle) {
				if utility.provider.isNotEmpty {
					HStack {
						Text("Provider:")
						SecondaryText(utility.provider)
							.textSelection(.enabled)
					}
				}

				if utility.accountNumber.isNotEmpty {
					HStack {
						Text("Account number:")
						SecondaryText(utility.accountNumber)
							.textSelection(.enabled)
					}
				}

				if let appxMonthlyCost = utility.approximateMonthlyCost {
					HStack {
						Text("Monthly cost:")
						SecondaryText("\(appxMonthlyCost.asCost)")
							.textSelection(.enabled)
					}
				}

				VStack(alignment: .leading) {
					Text("Notes:")

					TextEditor(text: $vm.utilityNotes)
						.textSelection(.enabled)
						.frame(minHeight: 40)
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
