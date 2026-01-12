//
//  SectionEditSheet.swift
//  YouHQ
//
//  Created by Ryan Token on 1/10/26.
//

import SQLiteData
import SwiftUI

enum EditableSection {
	case residenceInfo(Residence)
	case utility(Utility, isNew: Bool)
	case insurancePolicy(InsurancePolicy, isNew: Bool)
	case other(Other, isNew: Bool)

	var isNew: Bool {
		switch self {
		case .residenceInfo:
			false
		case .utility(_, let isNew):
			isNew
		case .insurancePolicy(_, let isNew):
			isNew
		case .other(_, let isNew):
			isNew
		}
	}
}

struct SectionEditSheet: View {
	@Environment(\.dismiss) private var dismiss
	@State private var vm: ViewModel
	@FocusState private var residenceFieldFocused: Bool
	@FocusState private var utilityFieldFocused: Bool
	@FocusState private var insuranceFieldFocused: Bool
	@FocusState private var otherFieldFocused: Bool

	init(section: EditableSection) {
		_vm = State(wrappedValue: ViewModel(section: section))
	}

	var body: some View {
		NavigationStack {
			Form {
				switch vm.section {
				case .residenceInfo:
					ResidenceInfoEditSection(
						vm: vm,
						focusedField: $residenceFieldFocused
					)
				case .utility:
					UtilityEditSection(
						vm: vm,
						focusedField: $utilityFieldFocused
					)
				case .insurancePolicy:
					InsuranceEditSection(
						vm: vm,
						focusedField: $insuranceFieldFocused
					)
				case .other:
					OtherEditSection(
						vm: vm,
						focusedField: $otherFieldFocused
					)
				}
			}
			.onAppear {
				if vm.section.isNew {
					switch vm.section {
					case .residenceInfo:
						residenceFieldFocused = true
					case .utility:
						utilityFieldFocused = true
					case .insurancePolicy:
						insuranceFieldFocused = true
					case .other:
						otherFieldFocused = true
					}
				}
			}
			#if os(macOS)
				.formStyle(.grouped)
				.frame(minWidth: 500, minHeight: 350)
			#else
				.frame(minHeight: 350)
			#endif
			.navigationTitle(vm.title)
			#if !os(macOS)
				.navigationBarTitleDisplayMode(.inline)
			#endif
			#if !os(visionOS)
				.scrollDismissesKeyboard(.immediately)
			#endif
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") {
						vm.cancel()
						dismiss()
					}
				}

				ToolbarItem(placement: .confirmationAction) {
					Button("Save") {
						vm.save()
						dismiss()
					}
					.disabled(!vm.isValid)
				}
			}
			.presentationDetents(
				vm.section.isNew ? [.large] : [.medium, .large]
			)
			.interactiveDismissDisabled(vm.section.isNew)
		}
	}
}

// MARK: - Residence Info Edit Section

private struct ResidenceInfoEditSection: View {
	@Bindable var vm: SectionEditSheet.ViewModel
	var focusedField: FocusState<Bool>.Binding

	var body: some View {
		ResidenceFormFields(
			type: $vm.residenceType,
			isCurrent: $vm.residenceIsCurrent,
			street: $vm.residenceStreet,
			unit: $vm.residenceUnit,
			city: $vm.residenceCity,
			state: $vm.residenceState,
			zipCode: $vm.residenceZipCode,
			country: $vm.residenceCountry,
			moveInDate: $vm.residenceMoveInDate,
			moveOutDate: $vm.residenceMoveOutDate,
			hasMoveOutDate: $vm.residenceHasMoveOutDate,
			costType: $vm.residenceCostType,
			monthlyCost: $vm.residenceMonthlyCost,
			showURLAndNotes: true,
			url: $vm.residenceURL,
			notes: $vm.residenceNotes,
			focusedField: focusedField
		)
	}
}

// MARK: - Utility Edit Section

private struct UtilityEditSection: View {
	@Bindable var vm: SectionEditSheet.ViewModel
	var focusedField: FocusState<Bool>.Binding

	var body: some View {
		Section("Utility Info") {
			LabeledField(label: "Type") {
				Picker(selection: $vm.utilityType) {
					ForEach(UtilityType.allCases, id: \.self) { type in
						Text(type.rawValue).tag(type)
					}
				} label: {
					EmptyView()
				}
			}

			LabeledField(label: "Provider") {
				TextField("", text: $vm.utilityProvider)
					.focused(focusedField)
					.multilineTextAlignment(.trailing)
			}
			#if !os(macOS)
				.textInputAutocapitalization(.words)
			#endif

			LabeledField(label: "Account Number") {
				TextField("", text: $vm.utilityAccountNumber)
					.multilineTextAlignment(.trailing)
			}

			LabeledField(label: "Appx Monthly Cost") {
				TextField(
					"",
					value: $vm.utilityMonthlyCost,
					format: .currency(code: "USD")
				)
				.multilineTextAlignment(.trailing)
			}
			#if !os(macOS)
				.keyboardType(.decimalPad)
			#endif
		}

		Section("Website") {
			URLTextField(text: $vm.utilityURL)
		}

		Section("Notes") {
			TextEditor(text: $vm.utilityNotes)
				.frame(minHeight: 100)
				.scrollContentBackground(.hidden)
		}
	}
}

// MARK: - Insurance Edit Section

private struct InsuranceEditSection: View {
	@Bindable var vm: SectionEditSheet.ViewModel
	var focusedField: FocusState<Bool>.Binding

	var body: some View {
		Section("Policy Info") {
			LabeledField(label: "Type") {
				Picker(selection: $vm.insuranceType) {
					ForEach(InsurancePolicyType.allCases.filter { $0 == .home || $0 == .renters }, id: \.self) { type in
						Text(type.rawValue).tag(type)
					}
				} label: {
					EmptyView()
				}
			}

			LabeledField(label: "Provider") {
				TextField("", text: $vm.insuranceProvider)
					.focused(focusedField)
					.multilineTextAlignment(.trailing)
			}
			#if !os(macOS)
				.textInputAutocapitalization(.words)
			#endif

			LabeledField(label: "Policy Number") {
				TextField("", text: $vm.insurancePolicyNumber)
					.multilineTextAlignment(.trailing)
			}
		}

		Section("Cost") {
			LabeledField(label: "Monthly Cost") {
				TextField(
					"",
					value: $vm.insuranceMonthlyCost,
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
					value: $vm.insuranceDeductible,
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
					value: $vm.insuranceCoverageAmount,
					format: .currency(code: "USD")
				)
				.multilineTextAlignment(.trailing)
			}
			#if !os(macOS)
				.keyboardType(.decimalPad)
			#endif
		}

		Section("Dates") {
			Toggle("Has Renewal Date", isOn: $vm.insuranceHasRenewalDate)

			if vm.insuranceHasRenewalDate {
				DatePicker(
					"Renewal Date",
					selection: Binding(
						get: { vm.insuranceRenewalDate ?? Date() },
						set: { vm.insuranceRenewalDate = $0 }
					),
					displayedComponents: .date
				)
			}
		}

		Section("Website") {
			URLTextField(text: $vm.insuranceURL)
		}

		Section("Notes") {
			TextEditor(text: $vm.insuranceNotes)
				.frame(minHeight: 100)
				.scrollContentBackground(.hidden)
		}
	}
}

#Preview("Residence Info") {
	SectionEditSheet(section: .residenceInfo(Residence.sampleData))
}

#Preview("Utility") {
	SectionEditSheet(section: .utility(Utility.sampleData, isNew: false))
}

#Preview("Insurance") {
	SectionEditSheet(
		section: .insurancePolicy(InsurancePolicy.sampleData, isNew: false)
	)
}

// MARK: - Other Edit Section

private struct OtherEditSection: View {
	@Bindable var vm: SectionEditSheet.ViewModel
	var focusedField: FocusState<Bool>.Binding

	var body: some View {
		Section("Basic Info") {
			LabeledField(label: "Name") {
				TextField("", text: $vm.otherName)
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
					value: $vm.otherMonthlyCost,
					format: .currency(code: "USD")
				)
				.multilineTextAlignment(.trailing)
			}
			#if !os(macOS)
				.keyboardType(.decimalPad)
			#endif
		}

		Section("Website") {
			URLTextField(text: $vm.otherURL)
		}

		Section("Notes") {
			TextEditor(text: $vm.otherNotes)
				.frame(minHeight: 100)
				.scrollContentBackground(.hidden)
		}
	}
}

#Preview("Other") {
	SectionEditSheet(section: .other(Other.sampleData, isNew: false))
}
