//
//  SubscriptionEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct SubscriptionEdit: View {
	let coordinator: SectionEditSheet.ViewModel
	var focusedField: FocusState<Bool>.Binding

	var body: some View {
		if let subscriptionVM = coordinator.subscriptionViewModel {
			@Bindable var vm = subscriptionVM
			Section("Subscription Info") {
				LabeledField(label: "Name") {
					TextField("", text: $vm.name)
						.focused(focusedField)
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField(label: "Category") {
					Picker(selection: $vm.category) {
						ForEach(SubscriptionCategory.allCases, id: \.self) { category in
							Text(category.rawValue).tag(category)
						}
					} label: {
						EmptyView()
					}
				}

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

				LabeledField(label: "Billing Cycle") {
					Picker(selection: $vm.billingCycle) {
						ForEach(BillingCycle.allCases, id: \.self) { cycle in
							Text(cycle.rawValue).tag(cycle)
						}
					} label: {
						EmptyView()
					}
				}

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

				LabeledField(label: "Active") {
					Toggle("", isOn: $vm.isActive)
						.labelsHidden()
				}
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
