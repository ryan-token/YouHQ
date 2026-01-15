//
//  SectionEditSheet.swift
//  YouHQ
//
//  Created by Ryan Token on 1/10/26.
//

import SwiftUI

struct SectionEditSheet: View {
	@State private var vm: ViewModel
	@State private var isShowingDeleteConfirmation = false
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
					ResidenceInfoEdit(
						coordinator: vm,
						focusedField: $residenceFieldFocused
					)
				case .utility:
					UtilityEdit(
						coordinator: vm,
						focusedField: $utilityFieldFocused
					)
				case .insurancePolicy:
					InsuranceEdit(
						coordinator: vm,
						focusedField: $insuranceFieldFocused
					)
				case .maintenanceItem:
					MaintenanceItemEdit(
						coordinator: vm,
						focusedField: $maintenanceFieldFocused
					)
				case .other:
					OtherEdit(
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
				Toolbar(vm: vm, isShowingDeleteConfirmation: $isShowingDeleteConfirmation)
			}
			.presentationDetents(
				vm.section.isNew ? [.large] : [.medium, .large]
			)
			.interactiveDismissDisabled(vm.section.isNew)
		}
	}
}
