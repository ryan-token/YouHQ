//
//  EditableSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import Foundation

/// Identifies which section the `SectionEditSheet` is editing and carries the
/// in-memory record to edit. Draft cases carry a freshly constructed value the
/// sheet will insert on save; non-draft cases carry the existing record.
enum EditableSection {
	case residenceInfo(Residence)
	case vehicleInfo(Vehicle)
	case utility(Utility)
	case utilityDraft(Utility)
	case insurancePolicy(InsurancePolicy)
	case insurancePolicyDraft(InsurancePolicy)
	case maintenanceItem(MaintenanceItem)
	case maintenanceItemDraft(MaintenanceItem)
	case paintColor(PaintColor)
	case paintColorDraft(PaintColor)
	case other(Other)
	case otherDraft(Other)
	case device(Device)
	case deviceDraft(Device)
	case serviceProvider(ServiceProvider)
	case serviceProviderDraft(ServiceProvider)
	case subscription(Subscription)
	case subscriptionDraft(Subscription)
	case job(Job)
	case jobDraft(Job)
	case bankAccount(BankAccount)
	case bankAccountDraft(BankAccount)
	case investmentAccount(InvestmentAccount)
	case investmentAccountDraft(InvestmentAccount)
	case healthSavingsAccount(HealthSavingsAccount)
	case healthSavingsAccountDraft(HealthSavingsAccount)

	var isDraft: Bool {
		switch self {
		case .residenceInfo, .vehicleInfo, .utility, .insurancePolicy, .maintenanceItem,
			.paintColor, .other, .device, .serviceProvider, .subscription, .job,
			.bankAccount, .investmentAccount, .healthSavingsAccount:
			false
		case .utilityDraft, .insurancePolicyDraft, .maintenanceItemDraft,
			.paintColorDraft, .otherDraft, .deviceDraft, .serviceProviderDraft,
			.subscriptionDraft, .jobDraft, .bankAccountDraft,
			.investmentAccountDraft, .healthSavingsAccountDraft:
			true
		}
	}
}
