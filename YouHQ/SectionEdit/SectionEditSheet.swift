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

	init(
		section: EditableSection,
		draftUtility: Binding<Utility?> = .constant(nil),
		draftInsurancePolicy: Binding<InsurancePolicy?> = .constant(nil),
		draftMaintenanceItem: Binding<MaintenanceItem?> = .constant(nil),
		draftPaintColor: Binding<PaintColor?> = .constant(nil),
		draftOther: Binding<Other?> = .constant(nil),
		draftJob: Binding<Job?> = .constant(nil),
		draftDevice: Binding<Device?> = .constant(nil),
		draftServiceProvider: Binding<ServiceProvider?> = .constant(nil),
		draftSubscription: Binding<Subscription?> = .constant(nil),
		draftBankAccount: Binding<BankAccount?> = .constant(nil),
		draftInvestmentAccount: Binding<InvestmentAccount?> = .constant(nil),
		draftHealthSavingsAccount: Binding<HealthSavingsAccount?> = .constant(nil)
	) {
		_vm = State(
			wrappedValue: ViewModel(
				section: section,
				draftUtility: draftUtility,
				draftInsurancePolicy: draftInsurancePolicy,
				draftMaintenanceItem: draftMaintenanceItem,
				draftOther: draftOther,
				draftPaintColor: draftPaintColor,
				draftJob: draftJob,
				draftDevice: draftDevice,
				draftServiceProvider: draftServiceProvider,
				draftSubscription: draftSubscription,
				draftBankAccount: draftBankAccount,
				draftInvestmentAccount: draftInvestmentAccount,
				draftHealthSavingsAccount: draftHealthSavingsAccount
			)
		)
	}

	var body: some View {
		NavigationStack {
			Form {
				// Profile picker section (only shows if supported and >1 profile)
				if vm.sectionViewModel.supportsProfileSwitching {
					ProfilePickerSection(
						profiles: vm.sectionViewModel.profiles,
						selectedProfileID: Binding(
							get: { vm.sectionViewModel.currentProfileID },
							set: { vm.sectionViewModel.currentProfileID = $0 }
						),
						itemName: vm.sectionViewModel.itemNameForProfilePicker,
						isNewItem: vm.section.isDraft
					)
				}

				switch vm.section {
				case .residenceInfo:
					ResidenceInfoEdit(
						coordinator: vm,
						autoFocus: vm.section.isDraft
					)
				case .vehicleInfo:
					VehicleInfoEdit(
						coordinator: vm,
						autoFocus: vm.section.isDraft
					)
				case .utility, .utilityDraft:
					UtilityEdit(
						coordinator: vm,
						autoFocus: vm.section.isDraft
					)
				case .insurancePolicy, .insurancePolicyDraft:
					InsuranceEdit(
						coordinator: vm,
						autoFocus: vm.section.isDraft
					)
				case .maintenanceItem, .maintenanceItemDraft:
					MaintenanceItemEdit(
						coordinator: vm,
						autoFocus: vm.section.isDraft
					)
				case .paintColor, .paintColorDraft:
					PaintColorEdit(
						coordinator: vm,
						autoFocus: vm.section.isDraft
					)
				case .other, .otherDraft:
					OtherEdit(
						coordinator: vm,
						autoFocus: vm.section.isDraft
					)
				case .job, .jobDraft:
					JobEdit(
						coordinator: vm,
						autoFocus: vm.section.isDraft
					)
				case .device, .deviceDraft:
					DeviceEdit(
						coordinator: vm,
						autoFocus: vm.section.isDraft
					)
				case .serviceProvider, .serviceProviderDraft:
					ServiceProviderEdit(
						coordinator: vm,
						autoFocus: vm.section.isDraft
					)
				case .subscription, .subscriptionDraft:
					SubscriptionEdit(
						coordinator: vm,
						autoFocus: vm.section.isDraft
					)
				case .bankAccount, .bankAccountDraft:
					BankAccountEdit(
						coordinator: vm,
						autoFocus: vm.section.isDraft
					)
				case .investmentAccount, .investmentAccountDraft:
					InvestmentAccountEdit(
						coordinator: vm,
						autoFocus: vm.section.isDraft
					)
				case .healthSavingsAccount, .healthSavingsAccountDraft:
					HealthSavingsAccountEdit(
						coordinator: vm,
						autoFocus: vm.section.isDraft
					)
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
			.interactiveDismissDisabled(vm.section.isDraft)
		}
		.photoViewerOverlayHost()
		#if os(iOS)
			.cameraOverlayHost()
		#endif
	}
}
