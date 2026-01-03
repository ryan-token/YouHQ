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
		Section(vm.utilityTitle) {
			if vm.utility.provider.isNotEmpty {
				HStack {
					Text("Provider:")
					SecondaryText(vm.utility.provider)
						.textSelection(.enabled)
				}
			}

			if vm.utility.accountNumber.isNotEmpty {
				HStack {
					Text("Account number:")
					SecondaryText(vm.utility.accountNumber)
						.textSelection(.enabled)
				}
			}

			if let appxMonthlyCost = vm.utility.approximateMonthlyCost {
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
			}
			.frame(minHeight: 50)
		}
	}
}

#Preview {
	UtilitySection(for: Utility.sampleData)
}
