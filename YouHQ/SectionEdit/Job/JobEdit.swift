//
//  JobEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct JobEdit: View {
	let coordinator: SectionEditSheet.ViewModel
	var focusedField: FocusState<Bool>.Binding

	var body: some View {
		if let jobVM = coordinator.jobViewModel {
			@Bindable var vm = jobVM
			Section("Job Info") {
				LabeledField(label: "Company") {
					TextField("", text: $vm.company)
						.focused(focusedField)
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField(label: "Title") {
					TextField("", text: $vm.jobTitle)
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField(label: "Employment Type") {
					Picker(selection: $vm.employmentType) {
						ForEach(EmploymentType.allCases, id: \.self) { type in
							HQText(type.rawValue).tag(type)
						}
					} label: {
						EmptyView()
					}
				}

				LabeledField(label: "Current Job") {
					Toggle(isOn: $vm.isCurrent) {
						EmptyView()
					}
				}

				LabeledField(label: "Start Date") {
					DatePicker(
						"",
						selection: Binding(
							get: { vm.startDate ?? Date() },
							set: { vm.startDate = $0 }
						),
						displayedComponents: [.date]
					)
					.labelsHidden()
				}

				LabeledField(label: "End Date") {
					DatePicker(
						"",
						selection: Binding(
							get: { vm.endDate ?? Date() },
							set: { vm.endDate = $0 }
						),
						displayedComponents: [.date]
					)
					.labelsHidden()
					.disabled(vm.isCurrent)
					.opacity(vm.isCurrent ? 0.5 : 1.0)
				}

				LabeledField(label: "Salary") {
					TextField(
						"",
						value: $vm.salary,
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
