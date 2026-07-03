//
//  ServiceProviderEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct ServiceProviderEdit: View {
	enum Field: Hashable {
		case name, accountNumber, url, notes
	}

	let coordinator: SectionEditSheet.ViewModel
	let autoFocus: Bool
	@FocusState private var focusedField: Field?
	@State private var hasAppeared = false

	var body: some View {
		if let serviceProviderVM = coordinator.serviceProviderViewModel {
			@Bindable var vm = serviceProviderVM
			Section("Service Provider Info") {
				LabeledField("Type") {
					Picker("", selection: $vm.providerType) {
						ForEach(ServiceProviderType.allCases, id: \.self) { type in
							HQText(type.rawValue).tag(type)
						}
					}
					.labelsHidden()
				}

				LabeledField("Name") {
					TextField("", text: $vm.name)
						.focused($focusedField, equals: .name)
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

				MoneyField("Monthly Cost", amount: $vm.monthlyCost)

				CurrencySelectorRow(currencyCode: $vm.currencyCode)
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
