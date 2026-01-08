//
//  Schema.swift
//  YouHQ
//
//  Created by Ryan Token on 12/29/25.
//

import Foundation
import SQLiteData

// MARK: - Table Models

@Table struct Profile: Identifiable {
	let id: UUID
	var name: String = "Default"
	var createdAt: Date = Date()
	var updatedAt: Date = Date()
}

// MARK: - Residence Section

@Table struct Residence: Identifiable, Hashable {
	let id: UUID
	let profileID: Profile.ID
	var type: ResidenceType = .apartment
	var street: String = ""
	var unit: String = ""
	var city: String = ""
	var state: String = ""
	var zipCode: String = ""
	var country: String = "USA"
	var moveInDate: Date?
	var moveOutDate: Date?
	var isCurrent: Bool = true
	var monthlyCost: Double?
	var costType: CostType = .rent
	var backgroundColor: String = "indigo"
	var notes: String = ""

	// Full address with all available fields
	var address: String {
		var components: [String] = []

		if let streetLine {
			components.append(streetLine)
		}

		if let cityStateZip {
			components.append(cityStateZip)
		}

		// Country (only if not USA)
		if !country.isEmpty && country != "USA" {
			components.append(country)
		}

		return components.joined(separator: ", ")
	}

	// Short address - street, unit, city, state
	var shortAddress: String {
		var components: [String] = []

		if let streetLine {
			components.append(streetLine)
		}

		if let cityState {
			components.append(cityState)
		}

		return components.joined(separator: ", ")
	}

	var unitOrStreet: String? {
		if unit.isNotEmpty {
			return unit
		} else if street.isNotEmpty {
			return street
		} else {
			return nil
		}
	}

	// MARK: - Helper Properties

	private var streetLine: String? {
		guard !street.isEmpty else { return nil }

		if !unit.isEmpty {
			return "\(street), \(unit)"
		} else {
			return street
		}
	}

	private var cityState: String? {
		let parts = [city, state].filter { !$0.isEmpty }
		return parts.isEmpty ? nil : parts.joined(separator: ", ")
	}

	private var cityStateZip: String? {
		var parts: [String] = []

		if !city.isEmpty {
			parts.append(city)
		}
		if !state.isEmpty {
			parts.append(state)
		}
		if !zipCode.isEmpty {
			parts.append(zipCode)
		}

		return parts.isEmpty ? nil : parts.joined(separator: " ")
	}
}

@Table struct Utility: Identifiable {
	let id: UUID
	let residenceID: Residence.ID
	var type: UtilityType = .electric
	var provider: String = ""
	var accountNumber: String = ""
	var approximateMonthlyCost: Double?
	var backgroundColor: String = "blue"
	var notes: String = ""
}

// MARK: - Vehicle Section

@Table struct Vehicle: Identifiable {
	let id: UUID
	let profileID: Profile.ID
	var type: VehicleType = .car
	var subType: VehicleSubType = .gas
	var make: String = ""
	var model: String = ""
	var year: String?
	var color: String?
	var vin: String?
	var backgroundColor: String = "teal"
	var notes: String = ""
}

// MARK: - Money Section

@Table struct BankAccount: Identifiable {
	let id: UUID
	let profileID: Profile.ID
	var bankName: String = ""
	var accountType: BankAccountType = .checking
	var accountNumber: String = ""  // Last 4 digits
	var routingNumber: String = ""
	var isActive: Bool = true
	var backgroundColor: String = "green"
	var notes: String = ""
}

@Table struct InvestmentAccount: Identifiable {
	let id: UUID
	let profileID: Profile.ID
	var institution: String = ""
	var accountType: InvestmentAccountType = .brokerage
	var accountNumber: String = ""  // Last 4 digits
	var isActive: Bool = true
	var backgroundColor: String = "mint"
	var notes: String = ""
}

@Table struct HealthSavingsAccount: Identifiable {
	let id: UUID
	let profileID: Profile.ID
	var accountType: HealthSavingsAccountType = .hsa
	var institution: String = ""
	var accountNumber: String = ""
	var isActive: Bool = true
	var backgroundColor: String = "cyan"
	var notes: String = ""
}

// MARK: - Media Section

@Table struct ServiceProvider: Identifiable {
	let id: UUID
	let profileID: Profile.ID
	var providerType: ServiceProviderType = .internet
	var name: String = ""
	var monthlyCost: Double?
	var accountNumber: String = ""
	var backgroundColor: String = "purple"
	var notes: String = ""
}

@Table struct Device: Identifiable {
	let id: UUID
	let profileID: Profile.ID
	var type: DeviceType = .computer
	var brand: String = ""
	var model: String = ""
	var serialNumber: String = ""
	var purchaseDate: Date?
	var backgroundColor: String = "pink"
	var notes: String = ""
}

@Table struct Subscription: Identifiable {
	let id: UUID
	let profileID: Profile.ID
	var name: String = ""
	var category: SubscriptionCategory = .streaming
	var monthlyCost: Double?
	var billingCycle: BillingCycle = .monthly
	var renewalDate: Date?
	var isActive: Bool = true
	var backgroundColor: String = "orange"
	var notes: String = ""
}

// MARK: - Career Section

@Table struct Job: Identifiable {
	let id: UUID
	let profileID: Profile.ID
	var company: String = ""
	var title: String = ""
	var startDate: Date?
	var endDate: Date?
	var isCurrent: Bool = false
	var salary: Double?
	var employmentType: EmploymentType = .fullTime
	var backgroundColor: String = "blue"
	var notes: String = ""
}

// MARK: - Insurance Section

@Table struct InsurancePolicy: Identifiable {
	let id: UUID
	let profileID: Profile.ID
	var type: InsurancePolicyType = .health
	var provider: String = ""
	var policyNumber: String = ""
	var monthlyCost: Double?
	var deductible: Double?
	var coverageAmount: Double?
	var startDate: Date?
	var renewalDate: Date?
	var isActive: Bool = true
	var backgroundColor: String = "red"
	var notes: String = ""
}

// MARK: - Enums

enum ResidenceType: String, Codable, CaseIterable, QueryBindable {
	case house = "House"
	case apartment = "Apartment"
	case condo = "Condo"
	case townhouse = "Townhouse"
	case other = "Other"
}

enum CostType: String, Codable, CaseIterable, QueryBindable {
	case rent = "Rent"
	case mortgage = "Mortgage"
	case owned = "Owned (No Payment)"
}

enum UtilityType: String, Codable, CaseIterable, QueryBindable {
	case electric = "Electric"
	case gas = "Gas"
	case water = "Water"
	case trash = "Trash"
	case sewage = "Sewage"
	case internet = "Internet"
	case other = "Other"
}

enum VehicleType: String, Codable, CaseIterable, QueryBindable {
	case car = "Car"
	case truck = "Truck"
	case suv = "SUV"
	case other = "Other"
}

enum VehicleSubType: String, Codable, CaseIterable, QueryBindable {
	case gas = "Gas"
	case electric = "Electric"
	case hybrid = "Hybrid"
	case pluginHybrid = "Plug-In Hybrid"
	case other = "Other"
}

enum BankAccountType: String, Codable, CaseIterable, QueryBindable {
	case checking = "Checking"
	case savings = "Savings"
	case moneyMarket = "Money Market"
	case cd = "CD"
	case other = "Other"
}

enum InvestmentAccountType: String, Codable, CaseIterable, QueryBindable {
	case traditional401k = "401(k)"
	case roth401k = "Roth 401(k)"
	case traditionalIRA = "Traditional IRA"
	case rothIRA = "Roth IRA"
	case brokerage = "Brokerage"
	case sep = "SEP IRA"
	case simple = "SIMPLE IRA"
	case other = "Other"
}

enum HealthSavingsAccountType: String, Codable, CaseIterable, QueryBindable {
	case hsa = "HSA"
	case fsa = "FSA"
}

enum ServiceProviderType: String, Codable, CaseIterable, QueryBindable {
	case internet = "Internet"
	case tv = "TV"
	case cell = "Cell"
}

enum DeviceType: String, Codable, CaseIterable, QueryBindable {
	case tv = "TV"
	case computer = "Computer"
	case monitor = "Monitor"
	case tablet = "Tablet"
	case phone = "Phone"
	case speaker = "Speaker"
	case webcam = "Webcam"
	case router = "Router"
	case gamingConsole = "Gaming Console"
	case other = "Other"
}

enum SubscriptionCategory: String, Codable, CaseIterable, QueryBindable {
	case streaming = "Streaming"
	case music = "Music"
	case news = "News"
	case software = "Software"
	case gaming = "Gaming"
	case cloud = "Cloud Storage"
	case other = "Other"
}

enum BillingCycle: String, Codable, CaseIterable, QueryBindable {
	case monthly = "Monthly"
	case annual = "Annual"
	case other = "Other"
}

enum EmploymentType: String, Codable, CaseIterable, QueryBindable {
	case fullTime = "Full-Time"
	case partTime = "Part-Time"
	case contract = "Contract"
	case freelance = "Freelance"
	case internship = "Internship"
}

enum InsurancePolicyType: String, Codable, CaseIterable, QueryBindable {
	case health = "Health"
	case dental = "Dental"
	case vision = "Vision"
	case life = "Life"
	case auto = "Auto"
	case home = "Home"
	case renters = "Renters"
	case disability = "Disability"
	case umbrella = "Umbrella"
	case pet = "Pet"
	case other = "Other"
}
