//
//  InsuranceEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import SwiftUI

struct InsuranceEdit: View {
	enum Field: Hashable {
		case provider, policyNumber, url, notes
	}

	let coordinator: SectionEditSheet.ViewModel
	let autoFocus: Bool
	@FocusState private var focusedField: Field?
	@State private var hasAppeared = false

	var body: some View {
		if let insuranceVM = coordinator.insuranceViewModel {
			@Bindable var vm = insuranceVM
			Section("Policy Info") {
				LabeledField("Type") {
					Picker("", selection: $vm.type) {
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
					}
					.labelsHidden()
					.disabled(vm.policy.vehicleID != nil)
				}

				LabeledField("Provider") {
					TextField("", text: $vm.provider)
						.focused($focusedField, equals: .provider)
						.onSubmit { focusedField = .policyNumber }
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField("Policy Number") {
					TextField("", text: $vm.policyNumber)
						.focused($focusedField, equals: .policyNumber)
						.onSubmit { focusedField = .url }
						.multilineTextAlignment(.trailing)
				}
			}
			.onAppear {
				if autoFocus, !hasAppeared {
					hasAppeared = true
					focusedField = .provider
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

				LabeledField("Deductible") {
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

				LabeledField("Coverage Amount") {
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
				LabeledField("Has Renewal Date") {
					Toggle("", isOn: $vm.hasRenewalDate)
						.labelsHidden()
				}

				if vm.hasRenewalDate {
					LabeledField("Renewal Date") {
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
					.focused($focusedField, equals: .url)
					.onSubmit { focusedField = .notes }
			}

			PhotoPickerSection(
				title: "Image",
				viewModel: vm.photoPicker
			)

			Section("Notes") {
				TextField("Notes", text: $vm.notes, axis: .vertical)
					.lineLimit(5...)
					.focused($focusedField, equals: .notes)
					.onSubmit { focusedField = nil }
			}
		}
	}
}

#Preview("Insurance") {
	SectionEditSheet(
		section: .insurancePolicy(InsurancePolicy.sampleData)
	)
}
