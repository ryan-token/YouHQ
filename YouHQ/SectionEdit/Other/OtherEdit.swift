//
//  OtherEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import SwiftUI

struct OtherEdit: View {
	enum Field: Hashable {
		case name, url, notes
	}

	let coordinator: SectionEditSheet.ViewModel
	let autoFocus: Bool
	@FocusState private var focusedField: Field?
	@State private var hasAppeared = false

	var body: some View {
		if let otherVM = coordinator.otherViewModel {
			@Bindable var vm = otherVM
			Section("Basic Info") {
				LabeledField("Name") {
					TextField("", text: $vm.name)
						.focused($focusedField, equals: .name)
						.onSubmit { focusedField = .url }
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField("Description") {
					TextField(
						"",
						text: $vm.otherDescription,
						axis: .vertical
					)
					.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.sentences)
				#endif
				.lineLimit(3...6)
			}
			.onAppear {
				if autoFocus, !hasAppeared {
					hasAppeared = true
					focusedField = .name
				}
			}

			Section("Cost") {
				LabeledField("Monthly Cost") {
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
					.focused($focusedField, equals: .url)
					.onSubmit { focusedField = .notes }
			}

			PhotoPickerSection(
				title: "Image",
				viewModel: vm.photoPicker
			)

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

#Preview("Other") {
	SectionEditSheet(
		section: .other(Other.sampleData),
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
