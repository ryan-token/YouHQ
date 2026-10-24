//
//  JobEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct JobEdit: View {
	enum Field: Hashable {
		case company, title, url, notes
	}

	let coordinator: SectionEditSheet.ViewModel
	let autoFocus: Bool
	@FocusState private var focusedField: Field?
	@State private var hasAppeared = false

	var body: some View {
		if let jobVM = coordinator.jobViewModel {
			@Bindable var vm = jobVM
			Section("Job Info") {
				LabeledField("Company") {
					TextField("", text: $vm.company)
						.focused($focusedField, equals: .company)
						.onSubmit { focusedField = .title }
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField("Title") {
					TextField("", text: $vm.jobTitle)
						.focused($focusedField, equals: .title)
						.onSubmit { focusedField = .url }
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField("Employment Type") {
					Picker("", selection: $vm.employmentType) {
						ForEach(EmploymentType.allCases, id: \.self) { type in
							HQText(type.rawValue).tag(type)
						}
					}
					.labelsHidden()
				}

				LabeledField("Current Job") {
					Toggle(isOn: $vm.isCurrent) {
						EmptyView()
					}
				}

				LabeledField("Start Date") {
					DatePicker(
						"",
						selection: $vm.startDate.orNow,
						displayedComponents: [.date]
					)
					.labelsHidden()
				}

				if !vm.isCurrent {
					LabeledField("End Date") {
						DatePicker(
							"",
							selection: $vm.endDate.orNow,
							displayedComponents: [.date]
						)
						.labelsHidden()
					}
				}

				MoneyField("Salary", amount: $vm.salary)

				CurrencySelectorRow(currencyCode: $vm.currencyCode)
			}
			.onAppear {
				if autoFocus, !hasAppeared {
					hasAppeared = true
					focusedField = .company
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
