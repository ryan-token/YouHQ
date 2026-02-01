//
//  BankAccountEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct BankAccountEdit: View {
	let coordinator: SectionEditSheet.ViewModel
	var focusedField: FocusState<Bool>.Binding

	var body: some View {
		if let bankAccountVM = coordinator.bankAccountViewModel {
			@Bindable var vm = bankAccountVM
			Section("Account Info") {
				LabeledField(label: "Bank Name") {
					TextField("", text: $vm.bankName)
						.focused(focusedField)
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField(label: "Account Type") {
					Picker(selection: $vm.accountType) {
						ForEach(BankAccountType.allCases, id: \.self) { type in
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

				LabeledField(label: "Routing Number") {
					TextField("", text: $vm.routingNumber)
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
