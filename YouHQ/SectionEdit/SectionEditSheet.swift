//
//  SectionEditSheet.swift
//  YouHQ
//
//  Created by Ryan Token on 1/10/26.
//

import SwiftUI

struct SectionEditSheet: View {
	@Environment(\.dismiss) private var dismiss
	@State private var vm: ViewModel
	@FocusState private var residenceFieldFocused: Bool
	@FocusState private var utilityFieldFocused: Bool
	@FocusState private var insuranceFieldFocused: Bool
	@FocusState private var maintenanceFieldFocused: Bool
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
						coordinator: vm,
						focusedField: $residenceFieldFocused
					)
				case .utility:
					UtilityEditSection(
						coordinator: vm,
						focusedField: $utilityFieldFocused
					)
				case .insurancePolicy:
					InsuranceEditSection(
						coordinator: vm,
						focusedField: $insuranceFieldFocused
					)
				case .maintenanceItem:
					MaintenanceItemEditSection(
						coordinator: vm,
						focusedField: $maintenanceFieldFocused
					)
				case .other:
					OtherEditSection(
						coordinator: vm,
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
					case .maintenanceItem:
						maintenanceFieldFocused = true
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
