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
				LabeledField("Account Type") {
					Picker("", selection: $vm.accountType) {
						ForEach(HealthSavingsAccountType.allCases, id: \.self) { type in
							HQText(type.rawValue).tag(type)
						}
					}
					.labelsHidden()
				}

				LabeledField("Institution") {
					TextField("", text: $vm.institution)
						.focused($focusedField, equals: .institution)
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

				LabeledField("Active") {
					Toggle("", isOn: $vm.isActive)
						.labelsHidden()
				}
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
				TextField("Notes", text: $vm.notes, axis: .vertical)
					.lineLimit(5...)
					.focused($focusedField, equals: .notes)
					.onSubmit { focusedField = nil }
			}
		}
	}
}
