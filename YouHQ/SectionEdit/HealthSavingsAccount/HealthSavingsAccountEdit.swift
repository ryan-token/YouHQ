//
//  HealthSavingsAccountEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct HealthSavingsAccountEdit: View {
	enum Field: Hashable {
		case institution, accountNumber, url, notes
	}

	let coordinator: SectionEditSheet.ViewModel
	let autoFocus: Bool
	@FocusState private var focusedField: Field?
	@State private var hasAppeared = false

	var body: some View {
		if let hsaVM = coordinator.healthSavingsAccountViewModel {
			@Bindable var vm = hsaVM
			Section("Account Info") {
				LabeledField(label: "Account Type") {
					Picker(selection: $vm.accountType) {
						ForEach(HealthSavingsAccountType.allCases, id: \.self) { type in
							HQText(type.rawValue).tag(type)
						}
					} label: {
						EmptyView()
					}
				}

				LabeledField(label: "Institution") {
					TextField("", text: $vm.institution)
						.focused($focusedField, equals: .institution)
						.onSubmit { focusedField = .accountNumber }
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField(label: "Account Number") {
					TextField("", text: $vm.accountNumber)
						.focused($focusedField, equals: .accountNumber)
						.onSubmit { focusedField = .url }
						.multilineTextAlignment(.trailing)
				}

				Toggle("Active", isOn: $vm.isActive)
			}
			.onAppear {
				if autoFocus, !hasAppeared {
					hasAppeared = true
					focusedField = .institution
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
