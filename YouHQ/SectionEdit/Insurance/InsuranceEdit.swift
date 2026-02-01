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
								if vm.policy.vehicleID != nil {
									return $0 == .auto
								} else {
									return $0 == .home || $0 == .renters
								}
							},
							id: \.self
						) { type in
							HQText(type.rawValue).tag(type)
						}
					} label: {
						EmptyView()
					}
					.disabled(vm.policy.vehicleID != nil)
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
				LabeledField(label: "Has Renewal Date") {
					Toggle("", isOn: $vm.hasRenewalDate)
						.labelsHidden()
				}

				if vm.hasRenewalDate {
					LabeledField(label: "Renewal Date") {
						DatePicker(
							"",
							selection: Binding(
								get: { vm.renewalDate ?? Date() },
								set: { vm.renewalDate = $0 }
							),
							displayedComponents: .date
						)
						.labelsHidden()
					}
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
		section: .insurancePolicy(InsurancePolicy.sampleData),
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
