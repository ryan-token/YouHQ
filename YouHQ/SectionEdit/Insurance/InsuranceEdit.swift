//
//  InsuranceEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import SwiftUI

struct InsuranceEdit: View {
	let coordinator: SectionEditSheet.ViewModel
	var focusedField: FocusState<Bool>.Binding

	var body: some View {
		if let insuranceVM = coordinator.insuranceViewModel {
			@Bindable var vm = insuranceVM
			Section("Policy Info") {
				LabeledField(label: "Type") {
					Picker(selection: $vm.type) {
						ForEach(
							InsurancePolicyType.allCases.filter {
								$0 == .home || $0 == .renters
							},
							id: \.self
						) { type in
							Text(type.rawValue).tag(type)
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

				LabeledField(label: "Policy Number") {
					TextField("", text: $vm.policyNumber)
						.multilineTextAlignment(.trailing)
				}
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

				LabeledField(label: "Deductible") {
					TextField(
						"",
						value: $vm.deductible,
						format: .currency(code: "USD")
					)
					.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.keyboardType(.decimalPad)
				#endif

				LabeledField(label: "Coverage Amount") {
					TextField(
						"",
						value: $vm.coverageAmount,
						format: .currency(code: "USD")
					)
					.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.keyboardType(.decimalPad)
				#endif
			}

			Section("Dates") {
				Toggle("Has Renewal Date", isOn: $vm.hasRenewalDate)

				if vm.hasRenewalDate {
					DatePicker(
						"Renewal Date",
						selection: Binding(
							get: { vm.renewalDate ?? Date() },
							set: { vm.renewalDate = $0 }
						),
						displayedComponents: .date
					)
				}
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

#Preview("Insurance") {
	SectionEditSheet(
		section: .insurancePolicy(InsurancePolicy.sampleData, isNew: false)
	)
}
