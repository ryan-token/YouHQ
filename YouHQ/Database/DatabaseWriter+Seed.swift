//
//  DatabaseWriter+Seed.swift
//  YouHQ
//
//  Created by Ryan Token on 1/13/26.
//

import Foundation
import SQLiteData

extension DatabaseWriter {
	func seed() throws {
		try write { db in
			@Dependency(\.date.now) var now

			// Ensure default profile exists (inline to avoid reentrancy)
			let existingProfiles = try Profile.fetchAll(db)
			let defaultProfile: Profile
			if let existing = existingProfiles.first(where: {
				$0.name == "Default"
			}) {
				defaultProfile = existing
			} else {
				try db.seed {
					Profile.Draft(
						name: "Default",
						createdAt: now,
						updatedAt: now
					)
				}
				let profiles = try Profile.fetchAll(db)
				guard
					let profile = profiles.first(where: { $0.name == "Default" }
					)
				else { return }
				defaultProfile = profile
			}

			try db.seed {
				// Create sample residence
				Residence.Draft(
					id: UUID(1),
					profileID: defaultProfile.id,
					type: .apartment,
					street: "123 Main St",
					unit: "Apt 4B",
					city: "San Francisco",
					state: "CA",
					zipCode: "94102",
					country: "USA",
					moveInDate: now.addingTimeInterval(-60 * 60 * 24 * 365 * 2),  // 2 years ago
					moveOutDate: nil,
					isCurrent: true,
					monthlyCost: 2500,
					costType: .rent,
					notes: "Great location, close to work"
				)

				// Utilities for the residence
				Utility.Draft(
					residenceID: UUID(1),
					type: .electric,
					provider: "PG&E",
					accountNumber: "1234567890",
					approximateMonthlyCost: 120,
					notes: ""
				)

				Utility.Draft(
					residenceID: UUID(1),
					type: .internet,
					provider: "Comcast",
					accountNumber: "9876543210",
					approximateMonthlyCost: 80,
					notes: "1Gbps plan"
				)

				// Bank account
				BankAccount.Draft(
					profileID: defaultProfile.id,
					bankName: "Chase",
					accountType: .checking,
					accountNumber: "1234",
					routingNumber: "123456789",
					isActive: true,
					notes: "Primary checking account"
				)

				// Investment account
				InvestmentAccount.Draft(
					profileID: defaultProfile.id,
					institution: "Vanguard",
					accountType: .roth401k,
					accountNumber: "5678",
					isActive: true,
					notes: "Company 401(k)"
				)

				// Health savings account
				HealthSavingsAccount.Draft(
					profileID: defaultProfile.id,
					accountType: .hsa,
					institution: "Fidelity",
					accountNumber: "9012",
					isActive: true,
					notes: "HSA from employer"
				)

				// Job
				Job.Draft(
					profileID: defaultProfile.id,
					company: "Tech Corp",
					title: "Senior iOS Developer",
					startDate: now.addingTimeInterval(-60 * 60 * 24 * 365 * 3),  // 3 years ago
					endDate: nil,
					isCurrent: true,
					salary: 150_000,
					employmentType: .fullTime,
					notes: "Great benefits and work-life balance"
				)

				// Service providers
				ServiceProvider.Draft(
					profileID: defaultProfile.id,
					providerType: .internet,
					name: "Comcast",
					monthlyCost: 80,
					accountNumber: "9876543210",
					notes: "Gigabit connection"
				)

				ServiceProvider.Draft(
					profileID: defaultProfile.id,
					providerType: .cell,
					name: "Verizon",
					monthlyCost: 75,
					accountNumber: "5551234567",
					notes: "Unlimited plan"
				)

				// Subscriptions
				Subscription.Draft(
					profileID: defaultProfile.id,
					name: "Netflix",
					category: .streaming,
					monthlyCost: 15.99,
					billingCycle: .monthly,
					renewalDate: now.addingTimeInterval(60 * 60 * 24 * 30),  // 1 month from now
					isActive: true,
					notes: "Premium plan"
				)

				Subscription.Draft(
					profileID: defaultProfile.id,
					name: "Spotify",
					category: .music,
					monthlyCost: 9.99,
					billingCycle: .monthly,
					renewalDate: now.addingTimeInterval(60 * 60 * 24 * 30),  // 1 month from now
					isActive: true,
					notes: "Individual plan"
				)

				// Insurance policies
				InsurancePolicy.Draft(
					profileID: defaultProfile.id,
					residenceID: nil,
					type: .health,
					provider: "Blue Cross",
					policyNumber: "BC123456789",
					monthlyCost: 350,
					deductible: 2000,
					coverageAmount: 1_000_000,
					startDate: now,
					renewalDate: now.addingTimeInterval(60 * 60 * 24 * 365),  // 1 year from now
					isActive: true,
					notes: "PPO plan through employer"
				)

				// Renters insurance for residence
				InsurancePolicy.Draft(
					profileID: defaultProfile.id,
					residenceID: UUID(1),
					type: .renters,
					provider: "State Farm",
					policyNumber: "SF987654321",
					monthlyCost: 35,
					deductible: 500,
					coverageAmount: 50_000,
					startDate: now.addingTimeInterval(-60 * 60 * 24 * 365),
					renewalDate: now.addingTimeInterval(60 * 60 * 24 * 60),
					isActive: true,
					notes: "Covers personal property and liability"
				)

				// Device
				Device.Draft(
					profileID: defaultProfile.id,
					type: .computer,
					brand: "Apple",
					model: "MacBook Pro 16\" M3 Max",
					serialNumber: "C02ABC123XYZ",
					purchaseDate: now.addingTimeInterval(-60 * 60 * 24 * 365),  // 1 year ago
					notes: "Work computer"
				)
			}

			print("✅ Sample data seeded successfully")
		}
	}
}
