//
//  Schema.swift
//  YouHQ
//
//  Created by Ryan Token on 12/29/25.
//

import Foundation
import SQLiteData

// swiftlint:disable file_length

// MARK: - Table Models

@Table nonisolated struct Profile: Identifiable, Hashable {
	let id: UUID
	var name: String = "Default"
	var createdAt: Date = Date()
	var updatedAt: Date = Date()
}

// MARK: - Residence Section

@Table nonisolated struct Residence: Identifiable, Hashable {
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
	var currencyCode: String?
	var costType: ResidenceCostType = .rent
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
		if country.isNotEmpty && country != "USA" {
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

	// MARK: - Helper Properties

	var unitOrStreet: String? {
		if unit.isNotEmpty {
			return unit
		} else if street.isNotEmpty {
			return street
		} else {
			return nil
		}
	}

	private var streetLine: String? {
		guard street.isNotEmpty else { return nil }

		if unit.isNotEmpty {
			return "\(street), \(unit)"
		} else {
			return street
		}
	}

	private var cityState: String? {
		let parts = [city, state].filter { $0.isNotEmpty }
		return parts.isEmpty ? nil : parts.joined(separator: ", ")
	}

	private var cityStateZip: String? {
		var parts: [String] = []

		if city.isNotEmpty {
			parts.append(city)
		}
		if state.isNotEmpty {
			parts.append(state)
		}
		if zipCode.isNotEmpty {
			parts.append(zipCode)
		}

		return parts.isEmpty ? nil : parts.joined(separator: " ")
	}
}

@Table nonisolated struct Utility: Identifiable {
	let id: UUID
	let residenceID: Residence.ID
	var type: UtilityType = .electric
	var provider: String = ""
	@Column(as: EncryptedString.self) var accountNumber: String = ""
	var approximateMonthlyCost: Double?
	var currencyCode: String?
	var backgroundColor: String = "blue"
	var url: String = ""
	var notes: String = ""
}

@Table nonisolated struct MaintenanceItem: Identifiable {
	let id: UUID
	let residenceID: Residence.ID?
	let vehicleID: Vehicle.ID?
	var name: String = ""
	var itemDescription: String = ""
	var intervalType: MaintenanceIntervalType = .month
	var intervalValue: Int = 1
	var lastCompletedAt: Date?
	var dueDate: Date?
	var shouldNotify: Bool = false
	var notificationIdentifier: String = ""
	var backgroundColor: String = "yellow"
	var url: String = ""
	var notes: String = ""
}

extension MaintenanceItem {
	/// Calculate if this item is past due
	var isPastDue: Bool {
		guard let dueDate else { return false }
		return dueDate < Date()
	}

	/// Calculate if this item is upcoming (due within 30 days)
	var isUpcoming: Bool {
		guard let dueDate else { return false }
		let thirtyDaysFromNow =
			Calendar.current.date(byAdding: .day, value: 30, to: Date())
			?? Date()
		return dueDate >= Date() && dueDate <= thirtyDaysFromNow
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

@Table nonisolated struct MaintenanceCompletion: Identifiable {
	let id: UUID
	let maintenanceItemID: MaintenanceItem.ID
	var completedAt: Date = Date()
	var notes: String = ""
}

@Table nonisolated struct PaintColor: Identifiable {
	let id: UUID
	let residenceID: Residence.ID?
	let vehicleID: Vehicle.ID?
	var manufacturer: String = ""
	var colorName: String = ""
	var colorCode: String = ""
	var room: String = ""
	var finish: PaintFinish = .eggshell
	var purchaseDate: Date?
	var surfaceType: String = ""
	var storePurchasedFrom: String = ""
	var applicationDate: Date?
	var backgroundColor: String = "purple"
	var url: String = ""
	var notes: String = ""
}

// MARK: - Vehicle Section

@Table nonisolated struct Vehicle: Identifiable, Equatable {
	let id: UUID
	let profileID: Profile.ID
	var type: VehicleType = .car
	var subType: VehicleSubType = .gas
	var make: String = ""
	var model: String = ""
	var year: String?
	var color: String?
	@Column(as: EncryptedString?.self) var vin: String?
	var monthlyCost: Double?
	var currencyCode: String?
	var costType: VehicleCostType = .owned
	var backgroundColor: String = "teal"
	var url: String = ""
	var notes: String = ""

	var displayName: String {
		var parts: [String] = []
		if year?.isEmpty == false {
			parts.append(year!)
		}
		if make.isNotEmpty {
			parts.append(make)
		}
		if model.isNotEmpty {
			parts.append(model)
		}
		return parts.isEmpty ? "Vehicle" : parts.joined(separator: " ")
	}
}

// MARK: - Money Section

@Table nonisolated struct BankAccount: Identifiable {
	let id: UUID
	let profileID: Profile.ID
	var bankName: String = ""
	var accountType: BankAccountType = .checking
	@Column(as: EncryptedString.self) var accountNumber: String = ""
	@Column(as: EncryptedString.self) var routingNumber: String = ""
	var isActive: Bool = true
	var backgroundColor: String = "green"
	var url: String = ""
	var notes: String = ""
}

@Table nonisolated struct InvestmentAccount: Identifiable {
	let id: UUID
	let profileID: Profile.ID
	var institution: String = ""
	var accountType: InvestmentAccountType = .brokerage
	@Column(as: EncryptedString.self) var accountNumber: String = ""
	var isActive: Bool = true
	var backgroundColor: String = "mint"
	var url: String = ""
	var notes: String = ""
}

@Table nonisolated struct HealthSavingsAccount: Identifiable {
	let id: UUID
	let profileID: Profile.ID
	var accountType: HealthSavingsAccountType = .hsa
	var institution: String = ""
	@Column(as: EncryptedString.self) var accountNumber: String = ""
	var isActive: Bool = true
	var backgroundColor: String = "cyan"
	var url: String = ""
	var notes: String = ""
}

// MARK: - Media Section

@Table nonisolated struct ServiceProvider: Identifiable {
	let id: UUID
	let profileID: Profile.ID
	var providerType: ServiceProviderType = .internet
	var name: String = ""
	var monthlyCost: Double?
	var currencyCode: String?
	@Column(as: EncryptedString.self) var accountNumber: String = ""
	var backgroundColor: String = "purple"
	var url: String = ""
	var notes: String = ""
}

@Table nonisolated struct Device: Identifiable {
	let id: UUID
	let profileID: Profile.ID
	var type: DeviceType = .computer
	var brand: String = ""
	var model: String = ""
	@Column(as: EncryptedString.self) var serialNumber: String = ""
	var purchaseDate: Date?
	var backgroundColor: String = "pink"
	var url: String = ""
	var notes: String = ""
}

@Table nonisolated struct Subscription: Identifiable {
	let id: UUID
	let profileID: Profile.ID
	var name: String = ""
	var category: SubscriptionCategory = .streaming
	var monthlyCost: Double?
	var currencyCode: String?
	var billingCycle: BillingCycle = .monthly
	var renewalDate: Date?
	var isActive: Bool = true
	var backgroundColor: String = "orange"
	var url: String = ""
	var notes: String = ""
}

// MARK: - Career Section

@Table nonisolated struct Job: Identifiable, Equatable {
	let id: UUID
	let profileID: Profile.ID
	var company: String = ""
	var title: String = ""
	var startDate: Date?
	var endDate: Date?
	var isCurrent: Bool = false
	@Column(as: EncryptedDouble?.self) var salary: Double?
	var currencyCode: String?
	var employmentType: EmploymentType = .fullTime
	var backgroundColor: String = "blue"
	var url: String = ""
	var notes: String = ""
}

// MARK: - Insurance Section

@Table nonisolated struct InsurancePolicy: Identifiable {
	let id: UUID
	let profileID: Profile.ID
	var residenceID: Residence.ID?
	var vehicleID: Vehicle.ID?
	var type: InsurancePolicyType = .health
	var provider: String = ""
	@Column(as: EncryptedString.self) var policyNumber: String = ""
	var monthlyCost: Double?
	var deductible: Double?
	var coverageAmount: Double?
	var currencyCode: String?
	var startDate: Date?
	var renewalDate: Date?
	var isActive: Bool = true
	var backgroundColor: String = "red"
	var url: String = ""
	var notes: String = ""
}

// MARK: - Other

@Table nonisolated struct Other: Identifiable, Equatable {
	let id: UUID
	let profileID: Profile.ID
	var residenceID: Residence.ID?
	var vehicleID: Vehicle.ID?
	var category: OtherCategory = .homes
	var name: String = ""
	var otherDescription: String = ""
	var monthlyCost: Double?
	var currencyCode: String?
	var backgroundColor: String = "gray"
	var url: String = ""
	var notes: String = ""
}

// MARK: - Assets

@Table nonisolated struct Asset: Identifiable {
	let id: UUID
	let profileID: Profile.ID
	let residenceID: Residence.ID?
	let vehicleID: Vehicle.ID?
	let insurancePolicyID: InsurancePolicy.ID?
	let maintenanceItemID: MaintenanceItem.ID?
	let deviceID: Device.ID?
	let otherID: Other.ID?
	let imageData: Data
}

// MARK: - App Settings

@Table("appSettings") nonisolated struct AppSettings: Identifiable {
	let id: UUID
	var reminderInterval: ReminderInterval = .none
	/// The app-wide default currency code (ISO 4217, e.g. "USD", "AUD").
	/// `nil` means "follow the device locale" — see `Currency.resolvedDefault`.
	var currencyCode: String?
}

// MARK: - Raw Representable Structs
// These are raw representable structs instead of enums to support backwards compatibility
// when syncing via iCloud. New cases can be added without breaking old app versions.

nonisolated struct ResidenceType: RawRepresentable, Hashable, QueryBindable {
	let rawValue: String

	static let house = Self(rawValue: "House")
	static let apartment = Self(rawValue: "Apartment")
	static let condo = Self(rawValue: "Condo")
	static let townhouse = Self(rawValue: "Townhouse")
	static let other = Self(rawValue: "Other")

	static let allCases: [Self] = [
		.house, .apartment, .condo, .townhouse, .other
	]
}

nonisolated struct ResidenceCostType: RawRepresentable, Hashable, QueryBindable {
	let rawValue: String

	static let rent = Self(rawValue: "Rent")
	static let mortgage = Self(rawValue: "Mortgage")
	static let owned = Self(rawValue: "Owned (No Payment)")

	static let allCases: [Self] = [.rent, .mortgage, .owned]
}

nonisolated struct UtilityType: RawRepresentable, Hashable, QueryBindable {
	let rawValue: String

	static let electric = Self(rawValue: "Electric")
	static let gas = Self(rawValue: "Gas")
	static let water = Self(rawValue: "Water")
	static let trash = Self(rawValue: "Trash")
	static let sewage = Self(rawValue: "Sewage")
	static let internet = Self(rawValue: "Internet")
	static let other = Self(rawValue: "Other")

	static let allCases: [Self] = [
		.electric, .gas, .water, .trash, .sewage, .internet, .other
	]
}

nonisolated struct VehicleType: RawRepresentable, Hashable, QueryBindable {
	let rawValue: String

	static let car = Self(rawValue: "Car")
	static let truck = Self(rawValue: "Truck")
	static let suv = Self(rawValue: "SUV")
	static let other = Self(rawValue: "Other")

	static let allCases: [Self] = [.car, .truck, .suv, .other]
}

nonisolated struct VehicleSubType: RawRepresentable, Hashable, QueryBindable {
	let rawValue: String

	static let gas = Self(rawValue: "Gas")
	static let electric = Self(rawValue: "Electric")
	static let hybrid = Self(rawValue: "Hybrid")
	static let pluginHybrid = Self(rawValue: "Plug-In Hybrid")
	static let other = Self(rawValue: "Other")

	static let allCases: [Self] = [
		.gas, .electric, .hybrid, .pluginHybrid, .other
	]
}

nonisolated struct VehicleCostType: RawRepresentable, Hashable, QueryBindable {
	let rawValue: String

	static let owned = Self(rawValue: "Owned (No Payment)")
	static let loanPayment = Self(rawValue: "Loan Payment")
	static let leasePayment = Self(rawValue: "Lease Payment")
	static let dealerPayment = Self(rawValue: "Dealer Payment")
	static let other = Self(rawValue: "Other")

	static let allCases: [Self] = [
		.owned, .loanPayment, .leasePayment, .dealerPayment, .other
	]
}

nonisolated struct BankAccountType: RawRepresentable, Hashable, QueryBindable {
	let rawValue: String

	static let checking = Self(rawValue: "Checking")
	static let savings = Self(rawValue: "Savings")
	static let moneyMarket = Self(rawValue: "Money Market")
	static let cd = Self(rawValue: "CD")
	static let other = Self(rawValue: "Other")

	static let allCases: [Self] = [
		.checking, .savings, .moneyMarket, .cd, .other
	]
}

nonisolated struct InvestmentAccountType: RawRepresentable, Hashable,
	QueryBindable
{
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
		.brokerage, .sep, .simple, .other
	]
}

nonisolated struct HealthSavingsAccountType: RawRepresentable, Hashable,
	QueryBindable
{
	let rawValue: String

	static let hsa = Self(rawValue: "HSA")
	static let fsa = Self(rawValue: "FSA")

	static let allCases: [Self] = [.hsa, .fsa]
}

nonisolated struct ServiceProviderType: RawRepresentable, Hashable,
	QueryBindable
{
	let rawValue: String

	static let internet = Self(rawValue: "Internet")
	static let tv = Self(rawValue: "TV")
	static let cell = Self(rawValue: "Cellular")

	static let allCases: [Self] = [.internet, .tv, .cell]
}

nonisolated struct DeviceType: RawRepresentable, Hashable, QueryBindable {
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
		.speaker, .webcam, .router, .gamingConsole, .other
	]
}

nonisolated struct SubscriptionCategory: RawRepresentable, Hashable,
	QueryBindable
{
	let rawValue: String

	static let streaming = Self(rawValue: "Streaming")
	static let music = Self(rawValue: "Music")
	static let news = Self(rawValue: "News")
	static let software = Self(rawValue: "Software")
	static let gaming = Self(rawValue: "Gaming")
	static let cloud = Self(rawValue: "Cloud Storage")
	static let other = Self(rawValue: "Other")

	static let allCases: [Self] = [
		.streaming, .music, .news, .software, .gaming, .cloud, .other
	]
}

nonisolated struct BillingCycle: RawRepresentable, Hashable, QueryBindable {
	let rawValue: String

	static let monthly = Self(rawValue: "Monthly")
	static let annual = Self(rawValue: "Annual")
	static let other = Self(rawValue: "Other")

	static let allCases: [Self] = [.monthly, .annual, .other]
}

nonisolated struct EmploymentType: RawRepresentable, Hashable, QueryBindable {
	let rawValue: String

	static let fullTime = Self(rawValue: "Full-Time")
	static let partTime = Self(rawValue: "Part-Time")
	static let contract = Self(rawValue: "Contract")
	static let freelance = Self(rawValue: "Freelance")
	static let internship = Self(rawValue: "Internship")

	static let allCases: [Self] = [
		.fullTime, .partTime, .contract, .freelance, .internship
	]
}

nonisolated struct InsurancePolicyType: RawRepresentable, Hashable,
	QueryBindable
{
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
		.home, .renters, .disability, .umbrella, .pet, .other
	]
}

nonisolated struct MaintenanceIntervalType: RawRepresentable, Hashable,
	QueryBindable
{
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

nonisolated struct PaintFinish: RawRepresentable, Hashable, QueryBindable {
	let rawValue: String

	static let matte = Self(rawValue: "Matte")
	static let eggshell = Self(rawValue: "Eggshell")
	static let satin = Self(rawValue: "Satin")
	static let semiGloss = Self(rawValue: "Semi-Gloss")
	static let gloss = Self(rawValue: "Gloss")

	static let allCases: [Self] = [
		.matte, .eggshell, .satin, .semiGloss, .gloss
	]
}

nonisolated struct OtherCategory: RawRepresentable, Hashable, QueryBindable {
	let rawValue: String

	static let homes = Self(rawValue: "Homes")
	static let vehicles = Self(rawValue: "Vehicles")
	static let money = Self(rawValue: "Money")
	static let media = Self(rawValue: "Media")
	static let career = Self(rawValue: "Career")
}

nonisolated struct ReminderInterval: RawRepresentable, Hashable, QueryBindable {
	let rawValue: String

	static let none = Self(rawValue: "None")
	static let daily = Self(rawValue: "Daily")
	static let weekly = Self(rawValue: "Weekly")
	static let monthly = Self(rawValue: "Monthly")
	static let quarterly = Self(rawValue: "Quarterly")
	static let annually = Self(rawValue: "Annually")

	static let allCases: [Self] = [
		.none, .daily, .weekly, .monthly, .quarterly, .annually
	]

	var displayName: String {
		switch self {
		case .none: "Never"
		default: rawValue
		}
	}
}
