//
//  UtilityEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import SwiftUI

struct UtilityEdit: View {
	enum Field: Hashable {
		case provider, accountNumber, url, notes
	}

	let coordinator: SectionEditSheet.ViewModel
	let autoFocus: Bool
	@FocusState private var focusedField: Field?
	@State private var hasAppeared = false

	var body: some View {
		if let utilityVM = coordinator.utilityViewModel {
			@Bindable var vm = utilityVM
			Section("Utility Info") {
				LabeledField("Type") {
					Picker("", selection: $vm.type) {
						ForEach(UtilityType.allCases, id: \.self) { type in
							HQText(type.rawValue).tag(type)
						}
					}
					.labelsHidden()
				}

				LabeledField("Provider") {
					TextField("", text: $vm.provider)
						.focused($focusedField, equals: .provider)
						.onSubmit { focusedField = .accountNumber }
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField("Account Number") {
					TextField("", text: $vm.accountNumber)
						.focused($focusedField, equals: .accountNumber)
						.onSubmit { focusedField = .url }
						.multilineTextAlignment(.trailing)
				}

				MoneyField("Appx Monthly Cost", amount: $vm.monthlyCost)

				CurrencySelectorRow(currencyCode: $vm.currencyCode)
			}
			.onAppear {
				if autoFocus, !hasAppeared {
					hasAppeared = true
					focusedField = .provider
				}
			}

			Section("Website") {
				URLTextField(text: $vm.url)
					.focused($focusedField, equals: .url)
					.onSubmit { focusedField = .notes }
			}

			Section("Notes") {
				TextField("Notes", text: $vm.notes, axis: .vertical)
					.lineLimit(5...)
					.focused($focusedField, equals: .notes)
					.onSubmit { focusedField = nil }
			}
		}
	}
}

#Preview("Utility") {
	SectionEditSheet(
		section: .utility(Utility.sampleData)
	)
}
