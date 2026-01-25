//
//  EditableSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import Foundation

enum EditableSection {
	case residenceInfo(Residence)
	case vehicleInfo(Vehicle)
	case utility(Utility)
	case utilityDraft
	case insurancePolicy(InsurancePolicy)
	case insurancePolicyDraft
	case maintenanceItem(MaintenanceItem)
	case maintenanceItemDraft
	case paintColor(PaintColor)
	case paintColorDraft
	case other(Other)
	case otherDraft
	case device(Device)
	case deviceDraft
	case serviceProvider(ServiceProvider)
	case serviceProviderDraft
	case subscription(Subscription)
	case subscriptionDraft
	case job(Job)
	case jobDraft
	case bankAccount(BankAccount)
	case bankAccountDraft
	case investmentAccount(InvestmentAccount)
	case investmentAccountDraft
	case healthSavingsAccount(HealthSavingsAccount)
	case healthSavingsAccountDraft

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
