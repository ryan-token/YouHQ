//
//  InvestmentAccountEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct InvestmentAccountEdit: View {
	let coordinator: SectionEditSheet.ViewModel
	var focusedField: FocusState<Bool>.Binding

	var body: some View {
		if let investmentAccountVM = coordinator.investmentAccountViewModel {
			@Bindable var vm = investmentAccountVM
			Section("Account Info") {
				LabeledField(label: "Institution") {
					TextField("", text: $vm.institution)
						.focused(focusedField)
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField(label: "Account Type") {
					Picker(selection: $vm.accountType) {
						ForEach(InvestmentAccountType.allCases, id: \.self) { type in
							HQText(type.rawValue).tag(type)
						}
					} label: {
						EmptyView()
					}
				}

				LabeledField(label: "Account Number") {
					TextField("", text: $vm.accountNumber)
						.multilineTextAlignment(.trailing)
				}

				Toggle("Active", isOn: $vm.isActive)
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
