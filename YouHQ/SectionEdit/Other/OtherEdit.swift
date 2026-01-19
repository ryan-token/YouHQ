//
//  OtherEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import SwiftUI

struct OtherEdit: View {
	let coordinator: SectionEditSheet.ViewModel
	var focusedField: FocusState<Bool>.Binding

	var body: some View {
		if let otherVM = coordinator.otherViewModel {
			@Bindable var vm = otherVM
			Section("Basic Info") {
				LabeledField(label: "Name") {
					TextField("", text: $vm.name)
						.focused(focusedField)
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField(label: "Description") {
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

			Section("Cost") {
				LabeledField(label: "Monthly Cost") {
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

			PhotoPickerSection(
				title: "Image",
				viewModel: vm.photoPicker
			)

			Section("Notes") {
				TextEditor(text: $vm.notes)
					.frame(minHeight: 100)
					.scrollContentBackground(.hidden)
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
		draftOther: .constant(nil)
	)
}
