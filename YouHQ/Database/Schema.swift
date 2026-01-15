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
	var url: String = ""
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
	var url: String = ""
	var notes: String = ""
}

@Table struct MaintenanceItem: Identifiable {
	let id: UUID
	let residenceID: Residence.ID?
	let vehicleID: Vehicle.ID?
	var name: String = ""
	var itemDescription: String = ""
	var intervalType: MaintenanceIntervalType = .month
	var intervalValue: Int = 1
	var lastCompletedAt: Date?
	var nextDueDate: Date?
	var shouldNotify: Bool = false
	var backgroundColor: String = "yellow"
	var url: String = ""
	var notes: String = ""

	/// Calculate if this item is past due
	var isPastDue: Bool {
		guard let nextDueDate else { return false }
		return nextDueDate < Date()
	}

	/// Calculate if this item is upcoming (due within 30 days)
	var isUpcoming: Bool {
		guard let nextDueDate else { return false }
		let thirtyDaysFromNow =
			Calendar.current.date(byAdding: .day, value: 30, to: Date())
			?? Date()
		return nextDueDate >= Date() && nextDueDate <= thirtyDaysFromNow
	}

	/// Calculate the next due date based on completed date and interval
	func calculateNextDueDate(from completedDate: Date) -> Date {
		let calendar = Calendar.current
		let component = intervalType.calendarComponent
		return calendar.date(
			byAdding: component,
			value: intervalValue,
			to: completedDate
		) ?? completedDate
	}
}

@Table struct MaintenanceCompletion: Identifiable {
	let id: UUID
	let maintenanceItemID: MaintenanceItem.ID
	var completedAt: Date = Date()
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
	var url: String = ""
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
	var url: String = ""
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
	var url: String = ""
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
	var url: String = ""
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
	var url: String = ""
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
	var url: String = ""
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
	var url: String = ""
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
	var url: String = ""
	var notes: String = ""
}

// MARK: - Insurance Section

@Table struct InsurancePolicy: Identifiable {
	let id: UUID
	let profileID: Profile.ID
	var residenceID: Residence.ID?
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
	var url: String = ""
	var notes: String = ""
}

// MARK: - Other

@Table struct Other: Identifiable {
	let id: UUID
	let profileID: Profile.ID
	var residenceID: Residence.ID?
	var name: String = ""
	var otherDescription: String = ""
	var monthlyCost: Double?
	var backgroundColor: String = "gray"
	var url: String = ""
	var notes: String = ""
}

// MARK: - Raw Representable Structs
// These are raw representable structs instead of enums to support backwards compatibility
// when syncing via iCloud. New cases can be added without breaking old app versions.

nonisolated struct ResidenceType: RawRepresentable, Hashable, Codable, QueryBindable {
	let rawValue: String

	static let house = Self(rawValue: "House")
	static let apartment = Self(rawValue: "Apartment")
	static let condo = Self(rawValue: "Condo")
	static let townhouse = Self(rawValue: "Townhouse")
	static let other = Self(rawValue: "Other")

	static let allCases: [Self] = [
		.house, .apartment, .condo, .townhouse, .other,
	]
}

nonisolated struct CostType: RawRepresentable, Hashable, Codable, QueryBindable {
	let rawValue: String

	static let rent = Self(rawValue: "Rent")
	static let mortgage = Self(rawValue: "Mortgage")
	static let owned = Self(rawValue: "Owned (No Payment)")

	static let allCases: [Self] = [.rent, .mortgage, .owned]
}

nonisolated struct UtilityType: RawRepresentable, Hashable, Codable, QueryBindable {
	let rawValue: String

	static let electric = Self(rawValue: "Electric")
	static let gas = Self(rawValue: "Gas")
	static let water = Self(rawValue: "Water")
	static let trash = Self(rawValue: "Trash")
	static let sewage = Self(rawValue: "Sewage")
	static let internet = Self(rawValue: "Internet")
	static let other = Self(rawValue: "Other")

	static let allCases: [Self] = [
		.electric, .gas, .water, .trash, .sewage, .internet, .other,
	]
}

nonisolated struct VehicleType: RawRepresentable, Hashable, Codable, QueryBindable {
	let rawValue: String

	static let car = Self(rawValue: "Car")
	static let truck = Self(rawValue: "Truck")
	static let suv = Self(rawValue: "SUV")
	static let other = Self(rawValue: "Other")

	static let allCases: [Self] = [.car, .truck, .suv, .other]
}

nonisolated struct VehicleSubType: RawRepresentable, Hashable, Codable, QueryBindable {
	let rawValue: String

	static let gas = Self(rawValue: "Gas")
	static let electric = Self(rawValue: "Electric")
	static let hybrid = Self(rawValue: "Hybrid")
	static let pluginHybrid = Self(rawValue: "Plug-In Hybrid")
	static let other = Self(rawValue: "Other")

	static let allCases: [Self] = [
		.gas, .electric, .hybrid, .pluginHybrid, .other,
	]
}

nonisolated struct BankAccountType: RawRepresentable, Hashable, Codable, QueryBindable {
	let rawValue: String

	static let checking = Self(rawValue: "Checking")
	static let savings = Self(rawValue: "Savings")
	static let moneyMarket = Self(rawValue: "Money Market")
	static let cd = Self(rawValue: "CD")
	static let other = Self(rawValue: "Other")

	static let allCases: [Self] = [
		.checking, .savings, .moneyMarket, .cd, .other,
	]
}

nonisolated struct InvestmentAccountType: RawRepresentable, Hashable, Codable, QueryBindable {
	let rawValue: String

	static let traditional401k = Self(rawValue: "401(k)")
	static let roth401k = Self(rawValue: "Roth 401(k)")
	static let traditionalIRA = Self(rawValue: "Traditional IRA")
	static let rothIRA = Self(rawValue: "Roth IRA")
	static let brokerage = Self(rawValue: "Brokerage")
	static let sep = Self(rawValue: "SEP IRA")
	static let simple = Self(rawValue: "SIMPLE IRA")
	static let other = Self(rawValue: "Other")

	static let allCases: [Self] = [
		.traditional401k, .roth401k, .traditionalIRA, .rothIRA,
		.brokerage, .sep, .simple, .other,
	]
}

nonisolated struct HealthSavingsAccountType: RawRepresentable, Hashable, Codable, QueryBindable {
	let rawValue: String

	static let hsa = Self(rawValue: "HSA")
	static let fsa = Self(rawValue: "FSA")

	static let allCases: [Self] = [.hsa, .fsa]
}

nonisolated struct ServiceProviderType: RawRepresentable, Hashable, Codable, QueryBindable {
	let rawValue: String

	static let internet = Self(rawValue: "Internet")
	static let tv = Self(rawValue: "TV")
	static let cell = Self(rawValue: "Cell")

	static let allCases: [Self] = [.internet, .tv, .cell]
}

nonisolated struct DeviceType: RawRepresentable, Hashable, Codable, QueryBindable {
	let rawValue: String

	static let tv = Self(rawValue: "TV")
	static let computer = Self(rawValue: "Computer")
	static let monitor = Self(rawValue: "Monitor")
	static let tablet = Self(rawValue: "Tablet")
	static let phone = Self(rawValue: "Phone")
	static let speaker = Self(rawValue: "Speaker")
	static let webcam = Self(rawValue: "Webcam")
	static let router = Self(rawValue: "Router")
	static let gamingConsole = Self(rawValue: "Gaming Console")
	static let other = Self(rawValue: "Other")

	static let allCases: [Self] = [
		.tv, .computer, .monitor, .tablet, .phone,
		.speaker, .webcam, .router, .gamingConsole, .other,
	]
}

nonisolated struct SubscriptionCategory: RawRepresentable, Hashable, Codable, QueryBindable {
	let rawValue: String

	static let streaming = Self(rawValue: "Streaming")
	static let music = Self(rawValue: "Music")
	static let news = Self(rawValue: "News")
	static let software = Self(rawValue: "Software")
	static let gaming = Self(rawValue: "Gaming")
	static let cloud = Self(rawValue: "Cloud Storage")
	static let other = Self(rawValue: "Other")

	static let allCases: [Self] = [
		.streaming, .music, .news, .software, .gaming, .cloud, .other,
	]
}

nonisolated struct BillingCycle: RawRepresentable, Hashable, Codable, QueryBindable {
	let rawValue: String

	static let monthly = Self(rawValue: "Monthly")
	static let annual = Self(rawValue: "Annual")
	static let other = Self(rawValue: "Other")

	static let allCases: [Self] = [.monthly, .annual, .other]
}

nonisolated struct EmploymentType: RawRepresentable, Hashable, Codable, QueryBindable {
	let rawValue: String

	static let fullTime = Self(rawValue: "Full-Time")
	static let partTime = Self(rawValue: "Part-Time")
	static let contract = Self(rawValue: "Contract")
	static let freelance = Self(rawValue: "Freelance")
	static let internship = Self(rawValue: "Internship")

	static let allCases: [Self] = [
		.fullTime, .partTime, .contract, .freelance, .internship,
	]
}

nonisolated struct InsurancePolicyType: RawRepresentable, Hashable, Codable, QueryBindable {
	let rawValue: String

	static let health = Self(rawValue: "Health")
	static let dental = Self(rawValue: "Dental")
	static let vision = Self(rawValue: "Vision")
	static let life = Self(rawValue: "Life")
	static let auto = Self(rawValue: "Auto")
	static let home = Self(rawValue: "Home")
	static let renters = Self(rawValue: "Renters")
	static let disability = Self(rawValue: "Disability")
	static let umbrella = Self(rawValue: "Umbrella")
	static let pet = Self(rawValue: "Pet")
	static let other = Self(rawValue: "Other")

	static let allCases: [Self] = [
		.health, .dental, .vision, .life, .auto,
		.home, .renters, .disability, .umbrella, .pet, .other,
	]
}

nonisolated struct MaintenanceIntervalType: RawRepresentable, Hashable, Codable, QueryBindable {
	let rawValue: String

	static let day = Self(rawValue: "Day")
	static let week = Self(rawValue: "Week")
	static let month = Self(rawValue: "Month")
	static let year = Self(rawValue: "Year")

	static let allCases: [Self] = [.day, .week, .month, .year]

	var calendarComponent: Calendar.Component {
		switch rawValue {
		case Self.day.rawValue: .day
		case Self.week.rawValue: .weekOfYear
		case Self.month.rawValue: .month
		case Self.year.rawValue: .year
		default: .day
		}
	}
}
