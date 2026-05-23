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

				LabeledField("Account Type") {
					Picker("", selection: $vm.accountType) {
						ForEach(BankAccountType.allCases, id: \.self) { type in
							HQText(type.rawValue).tag(type)
						}
					}
					.labelsHidden()
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

				LabeledField("Active") {
					Toggle("", isOn: $vm.isActive)
						.labelsHidden()
				}
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
				TextField("Notes", text: $vm.notes, axis: .vertical)
					.lineLimit(5...)
					.focused($focusedField, equals: .notes)
					.onSubmit { focusedField = nil }
			}
		}
	}
}
