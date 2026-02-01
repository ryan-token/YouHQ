//
//  UtilityEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import SwiftUI

struct UtilityEdit: View {
	let coordinator: SectionEditSheet.ViewModel
	var focusedField: FocusState<Bool>.Binding

	var body: some View {
		if let utilityVM = coordinator.utilityViewModel {
			@Bindable var vm = utilityVM
			Section("Utility Info") {
				LabeledField(label: "Type") {
					Picker(selection: $vm.type) {
						ForEach(UtilityType.allCases, id: \.self) { type in
							HQText(type.rawValue).tag(type)
						}
					} label: {
						EmptyView()
					}
				}

				LabeledField(label: "Provider") {
					TextField("", text: $vm.provider)
						.focused(focusedField)
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField(label: "Account Number") {
					TextField("", text: $vm.accountNumber)
						.multilineTextAlignment(.trailing)
				}

				LabeledField(label: "Appx Monthly Cost") {
					TextField(
						"",
						value: $vm.monthlyCost,
						format: .currency(code: "USD")
					)
					.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.keyboardType(.decimalPad)
				#endif
			}

			Section("Website") {
				URLTextField(text: $vm.url)
			}

			Section("Notes") {
				TextEditor(text: $vm.notes)
					.frame(minHeight: 100)
					.scrollContentBackground(.hidden)
			}
		}
	}
}

#Preview("Utility") {
	SectionEditSheet(
		section: .utility(Utility.sampleData),
		draftUtility: .constant(nil),
		draftInsurancePolicy: .constant(nil),
		draftMaintenanceItem: .constant(nil),
		draftPaintColor: .constant(nil),
		draftOther: .constant(nil),
		draftJob: .constant(nil),
		draftDevice: .constant(nil),
		draftServiceProvider: .constant(nil),
		draftSubscription: .constant(nil),
		draftBankAccount: .constant(nil),
		draftInvestmentAccount: .constant(nil),
		draftHealthSavingsAccount: .constant(nil)
	)
}
