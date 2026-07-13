//
//  SubscriptionEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct SubscriptionEdit: View {
	enum Field: Hashable {
		case name, url, notes
	}

	let coordinator: SectionEditSheet.ViewModel
	let autoFocus: Bool
	@FocusState private var focusedField: Field?
	@State private var hasAppeared = false

	var body: some View {
		if let subscriptionVM = coordinator.subscriptionViewModel {
			@Bindable var vm = subscriptionVM
			Section("Subscription Info") {
				LabeledField("Name") {
					TextField("", text: $vm.name)
						.focused($focusedField, equals: .name)
						.onSubmit { focusedField = .url }
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField("Category") {
					Picker("", selection: $vm.category) {
						ForEach(SubscriptionCategory.allCases, id: \.self) { category in
							HQText(category.rawValue).tag(category)
						}
					}
					.labelsHidden()
				}

				LabeledField("Billing Cycle") {
					Picker("", selection: $vm.billingCycle) {
						ForEach(BillingCycle.allCases, id: \.self) { cycle in
							HQText(cycle.rawValue).tag(cycle)
						}
					}
					.labelsHidden()
				}

				MoneyField(
					vm.billingCycle == .annual ? "Annual Cost" : "Monthly Cost",
					amount: $vm.monthlyCost
				)

				CurrencySelectorRow(currencyCode: $vm.currencyCode)

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

				LabeledField("Active") {
					Toggle("", isOn: $vm.isActive)
						.labelsHidden()
				}
			}
			.onAppear {
				if autoFocus, !hasAppeared {
					hasAppeared = true
					focusedField = .name
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
