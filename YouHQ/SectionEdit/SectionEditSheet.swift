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
	@FocusState private var vehicleFieldFocused: Bool
	@FocusState private var utilityFieldFocused: Bool
	@FocusState private var insuranceFieldFocused: Bool
	@FocusState private var maintenanceFieldFocused: Bool
	@FocusState private var paintColorFieldFocused: Bool
	@FocusState private var otherFieldFocused: Bool
	@FocusState private var bankAccountFieldFocused: Bool
	@FocusState private var investmentAccountFieldFocused: Bool
	@FocusState private var hsaFieldFocused: Bool
	@FocusState private var jobFieldFocused: Bool
	@FocusState private var deviceFieldFocused: Bool
	@FocusState private var serviceProviderFieldFocused: Bool
	@FocusState private var subscriptionFieldFocused: Bool

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
						focusedField: $residenceFieldFocused
					)
				case .vehicleInfo:
					VehicleInfoEdit(
						coordinator: vm,
						focusedField: $vehicleFieldFocused
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
				case .paintColor, .paintColorDraft:
					PaintColorEdit(
						coordinator: vm,
						focusedField: $paintColorFieldFocused
					)
				case .other, .otherDraft:
					OtherEdit(
						coordinator: vm,
						focusedField: $otherFieldFocused
					)
				case .job, .jobDraft:
					JobEdit(
						coordinator: vm,
						focusedField: $jobFieldFocused
					)
				case .device, .deviceDraft:
					DeviceEdit(
						coordinator: vm,
						focusedField: $deviceFieldFocused
					)
				case .serviceProvider, .serviceProviderDraft:
					ServiceProviderEdit(
						coordinator: vm,
						focusedField: $serviceProviderFieldFocused
					)
				case .subscription, .subscriptionDraft:
					SubscriptionEdit(
						coordinator: vm,
						focusedField: $subscriptionFieldFocused
					)
				case .bankAccount, .bankAccountDraft:
					BankAccountEdit(
						coordinator: vm,
						focusedField: $bankAccountFieldFocused
					)
				case .investmentAccount, .investmentAccountDraft:
					InvestmentAccountEdit(
						coordinator: vm,
						focusedField: $investmentAccountFieldFocused
					)
				case .healthSavingsAccount, .healthSavingsAccountDraft:
					HealthSavingsAccountEdit(
						coordinator: vm,
						focusedField: $hsaFieldFocused
					)
				}
			}
			.task {
				// Load profiles for profile switching
				await vm.sectionViewModel.loadProfiles()
			}
			.onAppear {
				if vm.section.isDraft {
					switch vm.section {
					case .residenceInfo:
						residenceFieldFocused = true
					case .vehicleInfo:
						vehicleFieldFocused = true
					case .utility, .utilityDraft:
						utilityFieldFocused = true
					case .insurancePolicy, .insurancePolicyDraft:
						insuranceFieldFocused = true
					case .maintenanceItem, .maintenanceItemDraft:
						maintenanceFieldFocused = true
					case .paintColor, .paintColorDraft:
						paintColorFieldFocused = true
					case .other, .otherDraft:
						otherFieldFocused = true
					case .job, .jobDraft:
						jobFieldFocused = true
					case .device, .deviceDraft:
						deviceFieldFocused = true
					case .serviceProvider, .serviceProviderDraft:
						serviceProviderFieldFocused = true
					case .subscription, .subscriptionDraft:
						subscriptionFieldFocused = true
					case .bankAccount, .bankAccountDraft:
						bankAccountFieldFocused = true
					case .investmentAccount, .investmentAccountDraft:
						investmentAccountFieldFocused = true
					case .healthSavingsAccount, .healthSavingsAccountDraft:
						hsaFieldFocused = true
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
