//
//  Schema+SampleData.swift
//  YouHQ
//
//  Created by Ryan Token on 1/2/26.
//

import Foundation

extension Profile {
	static let sampleData = Profile(
		id: UUID(),
		name: "John Doe",
		createdAt: Date(),
		updatedAt: Date()
	)
}

extension Residence {
	static let sampleData = Residence(
		id: UUID(),
		profileID: Profile.sampleData.id,
		type: .apartment,
		street: "123 Main Street",
		unit: "Apt 4B",
		city: "San Francisco",
		state: "CA",
		zipCode: "94102",
		country: "USA",
		moveInDate: Calendar.current.date(
			byAdding: .year,
			value: -2,
			to: Date()
		),
		moveOutDate: nil,
		isCurrent: true,
		monthlyCost: 2500.00,
		costType: .rent,
		notes: "Great location near downtown"
	)
}

extension Utility {
	static let sampleData = Utility(
		id: UUID(),
		residenceID: Residence.sampleData.id,
		type: .electric,
		provider: "PG&E",
		accountNumber: "1234567890",
		approximateMonthlyCost: 125.50,
		notes: "Average summer bill is higher"
	)
}

extension Vehicle {
	static let sampleData = Vehicle(
		id: UUID(),
		profileID: Profile.sampleData.id,
		type: .car,
		subType: .electric,
		make: "Tesla",
		model: "Model 3",
		year: "2023",
		color: "Midnight Silver Metallic",
		vin: "5YJ3E1EA1KF123456",
		notes: "Long range battery"
	)
}

extension BankAccount {
	static let sampleData = BankAccount(
		id: UUID(),
		profileID: Profile.sampleData.id,
		bankName: "Chase",
		accountType: .checking,
		accountNumber: "1234",
		routingNumber: "021000021",
		isActive: true,
		notes: "Primary checking account"
	)
}

extension InvestmentAccount {
	static let sampleData = InvestmentAccount(
		id: UUID(),
		profileID: Profile.sampleData.id,
		institution: "Vanguard",
		accountType: .roth401k,
		accountNumber: "5678",
		isActive: true,
		notes: "Company 401(k) with 5% match"
	)
}

extension HealthSavingsAccount {
	static let sampleData = HealthSavingsAccount(
		id: UUID(),
		profileID: Profile.sampleData.id,
		accountType: .hsa,
		institution: "Fidelity",
		accountNumber: "9012",
		isActive: true,
		notes: "Contributions through payroll"
	)
}

extension ServiceProvider {
	static let sampleData = ServiceProvider(
		id: UUID(),
		profileID: Profile.sampleData.id,
		providerType: .internet,
		name: "Comcast Xfinity",
		monthlyCost: 89.99,
		accountNumber: "1122334455",
		notes: "1 Gbps plan"
	)
}

extension Device {
	static let sampleData = Device(
		id: UUID(),
		profileID: Profile.sampleData.id,
		type: .computer,
		brand: "Apple",
		model: "MacBook Pro 16\"",
		serialNumber: "C02ABC123456",
		purchaseDate: Calendar.current.date(
			byAdding: .year,
			value: -1,
			to: Date()
		),
		notes: "M3 Max, 64GB RAM"
	)
}

extension Subscription {
	static let sampleData = Subscription(
		id: UUID(),
		profileID: Profile.sampleData.id,
		name: "Netflix",
		category: .streaming,
		monthlyCost: 15.49,
		billingCycle: .monthly,
		renewalDate: Calendar.current.date(
			byAdding: .month,
			value: 1,
			to: Date()
		),
		isActive: true,
		notes: "Premium plan with 4K"
	)
}

extension Job {
	static let sampleData = Job(
		id: UUID(),
		profileID: Profile.sampleData.id,
		company: "Tech Corp",
		title: "Senior Software Engineer",
		startDate: Calendar.current.date(
			byAdding: .year,
			value: -3,
			to: Date()
		),
		endDate: nil,
		isCurrent: true,
		salary: 150000.00,
		employmentType: .fullTime,
		notes: "Remote position"
	)
}

extension InsurancePolicy {
	static let sampleData = InsurancePolicy(
		id: UUID(),
		profileID: Profile.sampleData.id,
		residenceID: nil,
		type: .health,
		provider: "Blue Cross Blue Shield",
		policyNumber: "BCBS123456789",
		monthlyCost: 450.00,
		deductible: 2000.00,
		coverageAmount: 1000000.00,
		startDate: Date(timeIntervalSinceNow: -365 * 24 * 60 * 60),
		renewalDate: Date(timeIntervalSinceNow: 30 * 24 * 60 * 60),
		isActive: true,
		notes: "Family plan with dental included"
	)

	static let homeInsuranceSampleData = InsurancePolicy(
		id: UUID(),
		profileID: Profile.sampleData.id,
		residenceID: Residence.sampleData.id,
		type: .renters,
		provider: "State Farm",
		policyNumber: "SF987654321",
		monthlyCost: 35.00,
		deductible: 500.00,
		coverageAmount: 50000.00,
		startDate: Calendar.current.date(
			byAdding: .year,
			value: -1,
			to: Date()
		),
		renewalDate: Calendar.current.date(
			byAdding: .month,
			value: 2,
			to: Date()
		),
		isActive: true,
		notes: "Covers personal property and liability"
	)
}
