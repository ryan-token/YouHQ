//
//  Analytics.swift
//  YouHQ
//
//  Created by Ryan Token on 1/23/26.
//

import StoreKit
import TelemetryDeck

struct Analytics {
	static func sendSignal(_ signal: Signal) {
		TelemetryDeck.signal(signal.rawValue)
	}

	static func logError(id: ErrorID, message: String) {
		print("Error: \(id). Message: \(message)")
		TelemetryDeck.errorOccurred(id: id.rawValue, message: message)
	}

	static func trackPurchase(for transaction: Transaction) {
		TelemetryDeck.purchaseCompleted(transaction: transaction)
	}

	enum Signal: String {
		// Profiles
		case profileCreated = "Profile.created"
		case profileSwitched = "Profile.switched"
		case profileDeleted = "Profile.deleted"
		case profileShared = "Profile.shared"

		// Residences
		case residencesTabTapped = "Residence.Tab.tapped"
		case residenceCreated = "Residence.created"
		case residenceSwitched = "Residence.switched"
		case residenceDeleted = "Residence.deleted"
		case residenceUtilityCreated = "Residence.Utility.created"
		case residenceUtilityDeleted = "Residence.Utility.deleted"
		case residenceInsurancePolicyCreated = "Residence.InsurancePolicy.created"
		case residenceInsurancePolicyDeleted = "Residence.InsurancePolicy.deleted"
		case residenceMaintenanceItemCreated = "Residence.MaintenanceItem.created"
		case residenceMaintenanceItemDeleted = "Residence.MaintenanceItem.deleted"
		case residencePaintColorCreated = "Residence.PaintColor.created"
		case residencePaintColorDeleted = "Residence.PaintColor.deleted"
		case residenceOtherCreated = "Residence.Other.created"
		case residenceOtherDeleted = "Residence.Other.deleted"

		// Vehicles
		case vehiclesTabTapped = "Vehicle.Tab.tapped"
		case vehicleCreated = "Vehicle.created"
		case vehicleSwitched = "Vehicle.switched"
		case vehicleDeleted = "Vehicle.deleted"
		case vehicleInsurancePolicyCreated = "Vehicle.InsurancePolicy.created"
		case vehicleInsurancePolicyDeleted = "Vehicle.InsurancePolicy.deleted"
		case vehicleMaintenanceItemCreated = "Vehicle.MaintenanceItem.created"
		case vehicleMaintenanceItemDeleted = "Vehicle.MaintenanceItem.deleted"
		case vehiclePaintColorCreated = "Vehicle.PaintColor.created"
		case vehiclePaintColorDeleted = "Vehicle.PaintColor.deleted"
		case vehicleOtherCreated = "Vehicle.Other.created"
		case vehicleOtherDeleted = "Vehicle.Other.deleted"

		// Money
		case moneyTabTapped = "Money.Tab.tapped"
		case moneyBankAccountCreated = "Money.BankAccount.created"
		case moneyBankAccountDeleted = "Money.BankAccount.deleted"
		case moneyInvestmentAccountCreated = "Money.InvestmentAccount.created"
		case moneyInvestmentAccountDeleted = "Money.InvestmentAccount.deleted"
		case moneyHSACreated = "Money.HSA.created"
		case moneyHSADeleted = "Money.HSA.deleted"
		case moneyOtherCreated = "Money.Other.created"
		case moneyOtherDeleted = "Money.Other.deleted"

		// Media
		case mediaTabTapped = "Media.Tab.tapped"
		case mediaDeviceCreated = "Media.Device.created"
		case mediaDeviceDeleted = "Media.Device.deleted"
		case mediaServiceProviderCreated = "Media.ServiceProvider.created"
		case mediaServiceProviderDeleted = "Media.ServiceProvider.deleted"
		case mediaSubscriptionCreated = "Media.Subscription.created"
		case mediaSubscriptionDeleted = "Media.Subscription.deleted"
		case mediaOtherCreated = "Media.Other.created"
		case mediaOtherDeleted = "Media.Other.deleted"

		// Career
		case careerTabTapped = "Career.Tab.tapped"
		case careerJobCreated = "Career.Job.created"
		case careerJobDeleted = "Career.Job.deleted"
		case careerOtherCreated = "Career.Other.created"
		case careerOtherDeleted = "Career.Other.deleted"

		// Other
		case itemBackgroundColorChanged = "Item.BackgroundColor.changed"
	}

	enum ErrorID: String {
		// Profiles
		case profileSaveFailed = "Failed to save profile"
		case profileDeleteFailed = "Failed to delete profile"

		// Residences
		case residenceSaveFailed = "Failed to save residence"
		case residenceLoadFailed = "Failed to load residence data"
		case residenceDeleteFailed = "Failed to delete residence"

		// Utilities
		case utilitySaveFailed = "Failed to save utility"
		case utilityDeleteFailed = "Failed to delete utility"

		// Maintenance Items
		case maintenanceItemSaveFailed = "Failed to save maintenance item"
		case maintenanceItemDeleteFailed = "Failed to delete maintenance item"

		// Paint Colors
		case paintColorSaveFailed = "Failed to save paint color"
		case paintColorDeleteFailed = "Failed to delete paint color"

		// Insurance Policies
		case insurancePolicySaveFailed = "Failed to save insurance policy"
		case insurancePolicyDeleteFailed = "Failed to delete insurance policy"

		// Other
		case otherSaveFailed = "Failed to save other item"
		case otherDeleteFailed = "Failed to delete other item"

		// Devices
		case deviceSaveFailed = "Failed to save device"
		case deviceDeleteFailed = "Failed to delete device"

		// Service Providers
		case serviceProviderSaveFailed = "Failed to save service provider"
		case serviceProviderDeleteFailed = "Failed to delete service provider"

		// Subscriptions
		case subscriptionSaveFailed = "Failed to save subscription"
		case subscriptionDeleteFailed = "Failed to delete subscription"

		// Jobs
		case jobSaveFailed = "Failed to save job"
		case jobLoadFailed = "Failed to load job data"
		case jobDeleteFailed = "Failed to delete job"

		// CloudKit
		case profileShareFailed = "Failed to share profile"

		// Bank Accounts
		case bankAccountSaveFailed = "Failed to save bank account"
		case bankAccountDeleteFailed = "Failed to delete bank account"

		// Investment Accounts
		case investmentAccountSaveFailed = "Failed to save investment account"
		case investmentAccountDeleteFailed = "Failed to delete investment account"

		// Health Savings Accounts
		case hsaSaveFailed = "Failed to save HSA"
		case hsaDeleteFailed = "Failed to delete HSA"

		// General
		case photoSaveFailed = "Failed to save photo to library"
		case notificationsRequestFailed = "Failed to request notification permissions"
	}
}
