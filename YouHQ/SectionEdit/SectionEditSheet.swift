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
	@State private var isShowingDeleteConfirmation = false

	@FocusState private var residenceFieldFocused: Bool
	@FocusState private var utilityFieldFocused: Bool
	@FocusState private var insuranceFieldFocused: Bool
	@FocusState private var maintenanceFieldFocused: Bool
	@FocusState private var otherFieldFocused: Bool

	init(
		section: EditableSection,
		draftUtility: Binding<Utility?>,
		draftInsurancePolicy: Binding<InsurancePolicy?>,
		draftMaintenanceItem: Binding<MaintenanceItem?>,
		draftOther: Binding<Other?>
	) {
		_vm = State(
			wrappedValue: ViewModel(
				section: section,
				draftUtility: draftUtility,
				draftInsurancePolicy: draftInsurancePolicy,
				draftMaintenanceItem: draftMaintenanceItem,
				draftOther: draftOther
			)
		)
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
				case .utility, .utilityDraft:
					UtilityEdit(
						coordinator: vm,
						focusedField: $utilityFieldFocused
					)
				case .insurancePolicy, .insurancePolicyDraft:
					InsuranceEdit(
						coordinator: vm,
						focusedField: $insuranceFieldFocused
					)
				case .maintenanceItem, .maintenanceItemDraft:
					MaintenanceItemEdit(
						coordinator: vm,
						focusedField: $maintenanceFieldFocused
					)
				case .other, .otherDraft:
					OtherEdit(
						coordinator: vm,
						focusedField: $otherFieldFocused
					)
				}
			}
			.onAppear {
				if vm.section.isDraft {
					switch vm.section {
					case .residenceInfo:
						residenceFieldFocused = true
					case .utility, .utilityDraft:
						utilityFieldFocused = true
					case .insurancePolicy, .insurancePolicyDraft:
						insuranceFieldFocused = true
					case .maintenanceItem, .maintenanceItemDraft:
						maintenanceFieldFocused = true
					case .other, .otherDraft:
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
				Toolbar(
					vm: vm,
					isShowingDeleteConfirmation: $isShowingDeleteConfirmation,
					onDismiss: { dismiss() }
				)
			}
			#if os(iOS)
				.presentationDetents(
					UIDevice.current.userInterfaceIdiom == .pad
						? [.large]
						: (vm.section.isDraft ? [.large] : [.medium, .large])
				)
			#endif
			.interactiveDismissDisabled(vm.section.isDraft)
		}
		.photoViewerOverlayHost()
		#if os(iOS)
			.cameraOverlayHost()
		#endif
	}
}
