//
//  SectionEditSheet+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/10/26.
//

import SwiftUI

protocol SectionEditViewModel: AnyObject, Observable {
	var title: String { get }
	var isValid: Bool { get }
	var deleteConfirmationMessage: String { get }
	var profiles: [ProfileShare] { get }
	var currentProfileID: UUID { get set }
	var itemNameForProfilePicker: String { get }
	var supportsProfileSwitching: Bool { get }
	func save()
	func cancel()
	func delete()
	func loadProfiles() async
}

// Default implementations for items that don't support profile switching
extension SectionEditViewModel {
	var profiles: [ProfileShare] { [] }
	var currentProfileID: UUID {
		get { UUID() }
		set { _ = newValue }
	}
	var itemNameForProfilePicker: String { "" }
	var supportsProfileSwitching: Bool { false }
	func loadProfiles() async {}
}

extension SectionEditSheet {
	@Observable
	class ViewModel {
		let section: EditableSection
		let sectionViewModel: any SectionEditViewModel

		var title: String {
			sectionViewModel.title
		}

		var isValid: Bool {
			sectionViewModel.isValid
		}

		var deleteConfirmationMessage: String {
			sectionViewModel.deleteConfirmationMessage
		}

		let sectionString: String

		// swiftlint:disable:next cyclomatic_complexity
		init(
			section: EditableSection,
			draftUtility: Binding<Utility?>,
			draftInsurancePolicy: Binding<InsurancePolicy?>,
			draftMaintenanceItem: Binding<MaintenanceItem?>,
			draftOther: Binding<Other?>,
			draftPaintColor: Binding<PaintColor?>,
			draftJob: Binding<Job?>,
			draftDevice: Binding<Device?>,
			draftServiceProvider: Binding<ServiceProvider?>,
			draftSubscription: Binding<Subscription?>,
			draftBankAccount: Binding<BankAccount?>,
			draftInvestmentAccount: Binding<InvestmentAccount?>,
			draftHealthSavingsAccount: Binding<HealthSavingsAccount?>
		) {
			self.section = section

			switch section {
			case .residenceInfo(let residence):
				sectionViewModel = ResidenceInfoEdit.ViewModel(
					residence: residence
				)
				sectionString = "Residence"
			case .vehicleInfo(let vehicle):
				sectionViewModel = VehicleInfoEdit.ViewModel(
					vehicle: vehicle
				)
				sectionString = "Vehicle"
			case .utility(let utility):
				sectionViewModel = UtilityEdit.ViewModel(
					utility: utility,
					isNew: false
				)
				sectionString = "Utility"
			case .utilityDraft:
				guard let utility = draftUtility.wrappedValue else {
					fatalError(
						"Draft utility must exist for .utilityDraft case"
					)
				}
				sectionViewModel = UtilityEdit.ViewModel(
					utility: utility,
					isNew: true
				)
				sectionString = "Utility"
			case .insurancePolicy(let policy):
				sectionViewModel = InsuranceEdit.ViewModel(
					policy: policy,
					isNew: false
				)
				sectionString = "Policy"
			case .insurancePolicyDraft:
				guard let policy = draftInsurancePolicy.wrappedValue else {
					fatalError(
						"Draft policy must exist for .insurancePolicyDraft case"
					)
				}
				sectionViewModel = InsuranceEdit.ViewModel(
					policy: policy,
					isNew: true
				)
				sectionString = "Policy"
			case .maintenanceItem(let item):
				sectionViewModel = MaintenanceItemEdit.ViewModel(
					item: item,
					isNew: false
				)
				sectionString = "Maintenance Item"
			case .maintenanceItemDraft:
				guard let item = draftMaintenanceItem.wrappedValue else {
					fatalError(
						"Draft maintenance item must exist for .maintenanceItemDraft case"
					)
				}
				sectionViewModel = MaintenanceItemEdit.ViewModel(
					item: item,
					isNew: true
				)
				sectionString = "Maintenance Item"
			case .paintColor(let paintColor):
				sectionViewModel = PaintColorEdit.ViewModel(
					paintColor: paintColor,
					isNew: false
				)
				sectionString = "Paint Color"
			case .paintColorDraft:
				guard let paintColor = draftPaintColor.wrappedValue else {
					fatalError(
						"Draft paint color must exist for .paintColorDraft case"
					)
				}
				sectionViewModel = PaintColorEdit.ViewModel(
					paintColor: paintColor,
					isNew: true
				)
				sectionString = "Paint Color"
			case .other(let other):
				sectionViewModel = OtherEdit.ViewModel(
					other: other,
					isNew: false
				)
				sectionString = other.name
			case .otherDraft:
				guard let other = draftOther.wrappedValue else {
					fatalError("Draft other must exist for .otherDraft case")
				}
				sectionViewModel = OtherEdit.ViewModel(
					other: other,
					isNew: true
				)
				sectionString = other.name
			case .job(let job):
				sectionViewModel = JobEdit.ViewModel(
					job: job,
					isNew: false
				)
				sectionString = "Job"
			case .jobDraft:
				guard let job = draftJob.wrappedValue else {
					fatalError("Draft job must exist for .jobDraft case")
				}
				sectionViewModel = JobEdit.ViewModel(
					job: job,
					isNew: true
				)
				sectionString = "Job"
			case .device(let device):
				sectionViewModel = DeviceEdit.ViewModel(
					device: device,
					isNew: false
				)
				sectionString = "Device"
			case .deviceDraft:
				guard let device = draftDevice.wrappedValue else {
					fatalError("Draft device must exist for .deviceDraft case")
				}
				sectionViewModel = DeviceEdit.ViewModel(
					device: device,
					isNew: true
				)
				sectionString = "Device"
			case .serviceProvider(let serviceProvider):
				sectionViewModel = ServiceProviderEdit.ViewModel(
					serviceProvider: serviceProvider,
					isNew: false
				)
				sectionString = "Service Provider"
			case .serviceProviderDraft:
				guard let serviceProvider = draftServiceProvider.wrappedValue else {
					fatalError("Draft service provider must exist for .serviceProviderDraft case")
				}
				sectionViewModel = ServiceProviderEdit.ViewModel(
					serviceProvider: serviceProvider,
					isNew: true
				)
				sectionString = "Service Provider"
			case .subscription(let subscription):
				sectionViewModel = SubscriptionEdit.ViewModel(
					subscription: subscription,
					isNew: false
				)
				sectionString = "Subscription"
			case .subscriptionDraft:
				guard let subscription = draftSubscription.wrappedValue else {
					fatalError("Draft subscription must exist for .subscriptionDraft case")
				}
				sectionViewModel = SubscriptionEdit.ViewModel(
					subscription: subscription,
					isNew: true
				)
				sectionString = "Subscription"
			case .bankAccount(let account):
				sectionViewModel = BankAccountEdit.ViewModel(
					account: account,
					isNew: false
				)
				sectionString = "Bank Account"
			case .bankAccountDraft:
				guard let account = draftBankAccount.wrappedValue else {
					fatalError("Draft bank account must exist for .bankAccountDraft case")
				}
				sectionViewModel = BankAccountEdit.ViewModel(
					account: account,
					isNew: true
				)
				sectionString = "Bank Account"
			case .investmentAccount(let account):
				sectionViewModel = InvestmentAccountEdit.ViewModel(
					account: account,
					isNew: false
				)
				sectionString = "Investment Account"
			case .investmentAccountDraft:
				guard let account = draftInvestmentAccount.wrappedValue else {
					fatalError("Draft investment account must exist for .investmentAccountDraft case")
				}
				sectionViewModel = InvestmentAccountEdit.ViewModel(
					account: account,
					isNew: true
				)
				sectionString = "Investment Account"
			case .healthSavingsAccount(let account):
				sectionViewModel = HealthSavingsAccountEdit.ViewModel(
					account: account,
					isNew: false
				)
				sectionString = "HSA/FSA"
			case .healthSavingsAccountDraft:
				guard let account = draftHealthSavingsAccount.wrappedValue else {
					fatalError("Draft HSA/FSA must exist for .healthSavingsAccountDraft case")
				}
				sectionViewModel = HealthSavingsAccountEdit.ViewModel(
					account: account,
					isNew: true
				)
				sectionString = "HSA/FSA"
			}
		}

		func save() {
			// Validate profile-related items before saving
			if sectionViewModel.profiles.isNotEmpty {
				let currentProfileID = sectionViewModel.currentProfileID
				let profileExists = sectionViewModel.profiles.contains { $0.profile.id == currentProfileID }
				if !profileExists {
					Analytics.logError(
						id: .invalidProfileOnSave, message: "Attempted to save item with invalid profile ID: \(currentProfileID)")
					return
				}
			}
			sectionViewModel.save()
		}

		func cancel() {
			sectionViewModel.cancel()
		}

		func delete() {
			sectionViewModel.delete()
		}

		// Type-safe accessors for specific view models
		var residenceViewModel: ResidenceInfoEdit.ViewModel? {
			sectionViewModel as? ResidenceInfoEdit.ViewModel
		}

		var utilityViewModel: UtilityEdit.ViewModel? {
			sectionViewModel as? UtilityEdit.ViewModel
		}

		var insuranceViewModel: InsuranceEdit.ViewModel? {
			sectionViewModel as? InsuranceEdit.ViewModel
		}

		var maintenanceViewModel: MaintenanceItemEdit.ViewModel? {
			sectionViewModel as? MaintenanceItemEdit.ViewModel
		}

		var paintColorViewModel: PaintColorEdit.ViewModel? {
			sectionViewModel as? PaintColorEdit.ViewModel
		}

		var otherViewModel: OtherEdit.ViewModel? {
			sectionViewModel as? OtherEdit.ViewModel
		}

		var vehicleViewModel: VehicleInfoEdit.ViewModel? {
			sectionViewModel as? VehicleInfoEdit.ViewModel
		}

		var jobViewModel: JobEdit.ViewModel? {
			sectionViewModel as? JobEdit.ViewModel
		}

		var deviceViewModel: DeviceEdit.ViewModel? {
			sectionViewModel as? DeviceEdit.ViewModel
		}

		var serviceProviderViewModel: ServiceProviderEdit.ViewModel? {
			sectionViewModel as? ServiceProviderEdit.ViewModel
		}

		var subscriptionViewModel: SubscriptionEdit.ViewModel? {
			sectionViewModel as? SubscriptionEdit.ViewModel
		}

		var bankAccountViewModel: BankAccountEdit.ViewModel? {
			sectionViewModel as? BankAccountEdit.ViewModel
		}

		var investmentAccountViewModel: InvestmentAccountEdit.ViewModel? {
			sectionViewModel as? InvestmentAccountEdit.ViewModel
		}

		var healthSavingsAccountViewModel: HealthSavingsAccountEdit.ViewModel? {
			sectionViewModel as? HealthSavingsAccountEdit.ViewModel
		}
	}
}
