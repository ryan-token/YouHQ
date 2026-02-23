//
//  BankAccountEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct BankAccountEdit: View {
	enum Field: Hashable {
		case bankName, accountNumber, routingNumber, url, notes
	}

	let coordinator: SectionEditSheet.ViewModel
	let autoFocus: Bool
	@FocusState private var focusedField: Field?
	@State private var hasAppeared = false

	var body: some View {
		if let bankAccountVM = coordinator.bankAccountViewModel {
			@Bindable var vm = bankAccountVM
			Section("Account Info") {
				LabeledField("Bank Name") {
					TextField("", text: $vm.bankName)
						.focused($focusedField, equals: .bankName)
						.onSubmit { focusedField = .accountNumber }
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField("Account Type", shouldOverrideTap: false) {
					Picker(selection: $vm.accountType) {
						ForEach(BankAccountType.allCases, id: \.self) { type in
							HQText(type.rawValue).tag(type)
						}
					} label: {
						EmptyView()
					}
				}

				LabeledField("Account Number") {
					TextField("", text: $vm.accountNumber)
						.focused($focusedField, equals: .accountNumber)
						.onSubmit { focusedField = .routingNumber }
						.multilineTextAlignment(.trailing)
				}

				LabeledField("Routing Number") {
					TextField("", text: $vm.routingNumber)
						.focused($focusedField, equals: .routingNumber)
						.onSubmit { focusedField = .url }
						.multilineTextAlignment(.trailing)
				}

				Toggle("Active", isOn: $vm.isActive)
			}
			.onAppear {
				if autoFocus, !hasAppeared {
					hasAppeared = true
					focusedField = .bankName
				}
			}

			Section("Website") {
				URLTextField(text: $vm.url)
					.focused($focusedField, equals: .url)
					.onSubmit { focusedField = .notes }
			}

			Section("Notes") {
				TextEditor(text: $vm.notes)
					.frame(minHeight: 100)
					.scrollContentBackground(.hidden)
					.focused($focusedField, equals: .notes)
					.onSubmit { focusedField = nil }
			}
		}
	}
}
