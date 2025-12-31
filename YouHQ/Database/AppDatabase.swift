//
//  AppDatabase.swift
//  YouHQ
//
//  Created by Ryan Token on 12/29/25.
//

import Foundation
import SQLiteData

func appDatabase() throws -> any DatabaseWriter {
	var configuration = Configuration()
	configuration.foreignKeysEnabled = true
	configuration.prepareDatabase { db in
		try db.attachMetadatabase()

		#if DEBUG
			db.trace(options: .profile) {
				print("[DEBUG] \($0.expandedDescription)")
			}
		#endif
	}

	let database = try SQLiteData.defaultDatabase(configuration: configuration)
	print(
		"""
		YouHQ database:
		open "\(database.path)"
		"""
	)

	var migrator = DatabaseMigrator()
	#if DEBUG
		migrator.eraseDatabaseOnSchemaChange = true
	#endif

	// MARK: - Initial Migration

	migrator.registerMigration("Create initial tables") { db in
		// Profile table
		try #sql(
			"""
			CREATE TABLE "profiles" (
				"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
				"name" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'Default',
				"createdAt" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT (datetime('now')),
				"updatedAt" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT (datetime('now'))
			) STRICT
			"""
		)
		.execute(db)

		// Residence table
		try #sql(
			"""
			CREATE TABLE "residences" (
				"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
				"profileID" TEXT NOT NULL REFERENCES "profiles"("id") ON DELETE CASCADE,
				"type" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'apartment',
				"street" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"unit" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"city" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"state" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"zipCode" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"country" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'USA',
				"moveInDate" TEXT,
				"moveOutDate" TEXT,
				"isCurrent" INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 1,
				"monthlyCost" TEXT,
				"costType" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'rent',
				"notes" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT ''
			) STRICT
			"""
		)
		.execute(db)

		// Utility table
		try #sql(
			"""
			CREATE TABLE "utilities" (
				"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
				"residenceID" TEXT NOT NULL REFERENCES "residences"("id") ON DELETE CASCADE,
				"type" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'electric',
				"provider" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"accountNumber" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"approximateMonthlyCost" TEXT,
				"notes" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT ''
			) STRICT
			"""
		)
		.execute(db)

		// Utility table
		try #sql(
			"""
			CREATE TABLE "vehicles" (
				"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
				"profileID" TEXT NOT NULL REFERENCES "profiles"("id") ON DELETE CASCADE,
				"type" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'car',
				"subType" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'gas',
				"make" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"model" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"year" TEXT,
				"color" TEXT,
				"vin" TEXT,
				"notes" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT ''
			) STRICT
			"""
		)
		.execute(db)

		// Bank Account table
		try #sql(
			"""
			CREATE TABLE "bankAccounts" (
				"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
				"profileID" TEXT NOT NULL REFERENCES "profiles"("id") ON DELETE CASCADE,
				"bankName" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"accountType" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'checking',
				"accountNumber" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"routingNumber" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"isActive" INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 1,
				"notes" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT ''
			) STRICT
			"""
		)
		.execute(db)

		// Investment Account table
		try #sql(
			"""
			CREATE TABLE "investmentAccounts" (
				"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
				"profileID" TEXT NOT NULL REFERENCES "profiles"("id") ON DELETE CASCADE,
				"institution" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"accountType" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'brokerage',
				"accountNumber" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"isActive" INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 1,
				"notes" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT ''
			) STRICT
			"""
		)
		.execute(db)

		// Health Savings Account table
		try #sql(
			"""
			CREATE TABLE "healthSavingsAccounts" (
				"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
				"profileID" TEXT NOT NULL REFERENCES "profiles"("id") ON DELETE CASCADE,
				"accountType" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'hsa',
				"institution" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"accountNumber" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"isActive" INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 1,
				"notes" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT ''
			) STRICT
			"""
		)
		.execute(db)

		// Service Provider table
		try #sql(
			"""
			CREATE TABLE "serviceProviders" (
				"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
				"profileID" TEXT NOT NULL REFERENCES "profiles"("id") ON DELETE CASCADE,
				"providerType" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'internet',
				"name" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"monthlyCost" TEXT,
				"accountNumber" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"notes" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT ''
			) STRICT
			"""
		)
		.execute(db)

		// Device table
		try #sql(
			"""
			CREATE TABLE "devices" (
				"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
				"profileID" TEXT NOT NULL REFERENCES "profiles"("id") ON DELETE CASCADE,
				"type" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'computer',
				"brand" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"model" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"serialNumber" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"purchaseDate" TEXT,
				"notes" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT ''
			) STRICT
			"""
		)
		.execute(db)

		// Subscription table
		try #sql(
			"""
			CREATE TABLE "subscriptions" (
				"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
				"profileID" TEXT NOT NULL REFERENCES "profiles"("id") ON DELETE CASCADE,
				"name" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"category" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'streaming',
				"monthlyCost" TEXT,
				"billingCycle" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'monthly',
				"renewalDate" TEXT,
				"isActive" INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 1,
				"notes" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT ''
			) STRICT
			"""
		)
		.execute(db)

		// Job table
		try #sql(
			"""
			CREATE TABLE "jobs" (
				"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
				"profileID" TEXT NOT NULL REFERENCES "profiles"("id") ON DELETE CASCADE,
				"company" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"title" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"startDate" TEXT,
				"endDate" TEXT,
				"isCurrent" INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
				"salary" TEXT,
				"employmentType" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'fullTime',
				"notes" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT ''
			) STRICT
			"""
		)
		.execute(db)

		// Insurance Policy table
		try #sql(
			"""
			CREATE TABLE "insurancePolicies" (
				"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
				"profileID" TEXT NOT NULL REFERENCES "profiles"("id") ON DELETE CASCADE,
				"type" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'health',
				"provider" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"policyNumber" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"monthlyCost" TEXT,
				"deductible" TEXT,
				"coverageAmount" TEXT,
				"startDate" TEXT,
				"renewalDate" TEXT,
				"isActive" INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 1,
				"notes" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT ''
			) STRICT
			"""
		)
		.execute(db)
	}

	// MARK: - Foreign Key Indexes

	migrator.registerMigration("Create foreign key indexes") { db in
		try #sql(
			"""
			CREATE INDEX "idx_residences_profileID" ON "residences"("profileID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_utilities_residenceID" ON "utilities"("residenceID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_vehicles_profileID" ON "vehicles"("profileID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_bankAccounts_profileID" ON "bankAccounts"("profileID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_investmentAccounts_profileID" ON "investmentAccounts"("profileID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_healthSavingsAccounts_profileID" ON "healthSavingsAccounts"("profileID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_serviceProviders_profileID" ON "serviceProviders"("profileID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_devices_profileID" ON "devices"("profileID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_subscriptions_profileID" ON "subscriptions"("profileID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_jobs_profileID" ON "jobs"("profileID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_insurancePolicies_profileID" ON "insurancePolicies"("profileID")
			"""
		)
		.execute(db)
	}

	// MARK: - Additional Indexes for Common Queries

	migrator.registerMigration("Create query optimization indexes") { db in
		// Index for finding current residence
		try #sql(
			"""
			CREATE INDEX "idx_residences_isCurrent" ON "residences"("isCurrent") WHERE "isCurrent" = 1
			"""
		)
		.execute(db)

		// Index for finding current job
		try #sql(
			"""
			CREATE INDEX "idx_jobs_isCurrent" ON "jobs"("isCurrent") WHERE "isCurrent" = 1
			"""
		)
		.execute(db)

		// Index for finding active accounts
		try #sql(
			"""
			CREATE INDEX "idx_bankAccounts_isActive" ON "bankAccounts"("isActive") WHERE "isActive" = 1
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_investmentAccounts_isActive" ON "investmentAccounts"("isActive") WHERE "isActive" = 1
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_healthSavingsAccounts_isActive" ON "healthSavingsAccounts"("isActive") WHERE "isActive" = 1
			"""
		)
		.execute(db)

		// Index for finding active subscriptions
		try #sql(
			"""
			CREATE INDEX "idx_subscriptions_isActive" ON "subscriptions"("isActive") WHERE "isActive" = 1
			"""
		)
		.execute(db)

		// Index for finding active insurance policies
		try #sql(
			"""
			CREATE INDEX "idx_insurancePolicies_isActive" ON "insurancePolicies"("isActive") WHERE "isActive" = 1
			"""
		)
		.execute(db)
	}

	// MARK: - Triggers

	migrator.registerMigration("Create triggers") { db in
		// Ensure at least one profile exists
		try #sql(
			"""
			CREATE TRIGGER "ensure_default_profile"
			AFTER DELETE ON "profiles"
			WHEN (SELECT COUNT(*) FROM "profiles") = 0
			BEGIN
				INSERT INTO "profiles" ("name") VALUES ('Default');
			END
			"""
		)
		.execute(db)

		// Update profile timestamp when residences change
		try #sql(
			"""
			CREATE TRIGGER "update_profile_on_residence_insert"
			AFTER INSERT ON "residences"
			BEGIN
				UPDATE "profiles" 
				SET "updatedAt" = datetime('now')
				WHERE "id" = NEW."profileID";
			END
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE TRIGGER "update_profile_on_residence_update"
			AFTER UPDATE ON "residences"
			BEGIN
				UPDATE "profiles" 
				SET "updatedAt" = datetime('now')
				WHERE "id" = NEW."profileID";
			END
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE TRIGGER "update_profile_on_residence_delete"
			AFTER DELETE ON "residences"
			BEGIN
				UPDATE "profiles" 
				SET "updatedAt" = datetime('now')
				WHERE "id" = OLD."profileID";
			END
			"""
		)
		.execute(db)

		// Create triggers for all other tables
		let tables = [
			"bankAccounts",
			"investmentAccounts",
			"healthSavingsAccounts",
			"serviceProviders",
			"devices",
			"subscriptions",
			"jobs",
			"insurancePolicies",
		]

		for table in tables {
			try #sql(
				"""
				CREATE TRIGGER "update_profile_on_\(raw: table)_insert"
				AFTER INSERT ON "\(raw: table)"
				BEGIN
					UPDATE "profiles" 
					SET "updatedAt" = datetime('now')
					WHERE "id" = NEW."profileID";
				END
				"""
			)
			.execute(db)

			try #sql(
				"""
				CREATE TRIGGER "update_profile_on_\(raw: table)_update"
				AFTER UPDATE ON "\(raw: table)"
				BEGIN
					UPDATE "profiles" 
					SET "updatedAt" = datetime('now')
					WHERE "id" = NEW."profileID";
				END
				"""
			)
			.execute(db)

			try #sql(
				"""
				CREATE TRIGGER "update_profile_on_\(raw: table)_delete"
				AFTER DELETE ON "\(raw: table)"
				BEGIN
					UPDATE "profiles" 
					SET "updatedAt" = datetime('now')
					WHERE "id" = OLD."profileID";
				END
				"""
			)
			.execute(db)
		}
	}

	try migrator.migrate(database)
	return database
}

// MARK: - Bootstrap

extension DependencyValues {
	mutating func bootstrapDatabase() throws {
		defaultDatabase = try appDatabase()
		try defaultDatabase.ensureDefaultProfile()
	}
}

// MARK: - Default Profile Creation

extension DatabaseWriter {
	/// Ensures at least one profile exists in the database
	/// Creates a default "Default" profile if none exist
	func ensureDefaultProfile() throws {
		try write { db in
			let profileCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM profiles") ?? 0

			guard profileCount == 0 else {
				print("ℹ️ Profile already exists, skipping default profile creation")
				return
			}

			@Dependency(\.date.now) var now
			@Dependency(\.uuid) var uuid

			try db.seed {
				Profile(
					id: uuid(),
					name: "Default",
					createdAt: now,
					updatedAt: now
				)
			}

			print("✅ Default profile created successfully")
		}
	}
}

// MARK: - Database Seeding Extension

extension DatabaseWriter {
	func seed() throws {
		try write { db in
			// Check if already seeded
			let profileCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM profiles") ?? 0
			guard profileCount == 0 else {
				print("ℹ️ Database already seeded, skipping")
				return
			}

			@Dependency(\.date.now) var now
			@Dependency(\.uuid) var uuid

			let profileID = uuid()
			let residenceID = uuid()

			try db.seed {
				// Create sample profile
				Profile(
					id: profileID,
					name: "Sample Life",
					createdAt: now,
					updatedAt: now
				)

				// Create sample residence
				Residence(
					id: residenceID,
					profileID: profileID,
					type: .apartment,
					street: "123 Main St",
					unit: "Apt 4B",
					city: "San Francisco",
					state: "CA",
					zipCode: "94102",
					country: "USA",
					moveInDate: now.addingTimeInterval(-60 * 60 * 24 * 365 * 2), // 2 years ago
					moveOutDate: nil,
					isCurrent: true,
					monthlyCost: 2500,
					costType: .rent,
					notes: "Great location, close to work"
				)

				// Utilities for the residence
				Utility(
					id: uuid(),
					residenceID: residenceID,
					type: .electric,
					provider: "PG&E",
					accountNumber: "1234567890",
					approximateMonthlyCost: 120,
					notes: ""
				)

				Utility(
					id: uuid(),
					residenceID: residenceID,
					type: .internet,
					provider: "Comcast",
					accountNumber: "9876543210",
					approximateMonthlyCost: 80,
					notes: "1Gbps plan"
				)

				// Bank account
				BankAccount(
					id: uuid(),
					profileID: profileID,
					bankName: "Chase",
					accountType: .checking,
					accountNumber: "1234",
					routingNumber: "123456789",
					isActive: true,
					notes: "Primary checking account"
				)

				// Investment account
				InvestmentAccount(
					id: uuid(),
					profileID: profileID,
					institution: "Vanguard",
					accountType: .roth401k,
					accountNumber: "5678",
					isActive: true,
					notes: "Company 401(k)"
				)

				// Health savings account
				HealthSavingsAccount(
					id: uuid(),
					profileID: profileID,
					accountType: .hsa,
					institution: "Fidelity",
					accountNumber: "9012",
					isActive: true,
					notes: "HSA from employer"
				)

				// Job
				Job(
					id: uuid(),
					profileID: profileID,
					company: "Tech Corp",
					title: "Senior iOS Developer",
					startDate: now.addingTimeInterval(-60 * 60 * 24 * 365 * 3), // 3 years ago
					endDate: nil,
					isCurrent: true,
					salary: 150_000,
					employmentType: .fullTime,
					notes: "Great benefits and work-life balance"
				)

				// Service providers
				ServiceProvider(
					id: uuid(),
					profileID: profileID,
					providerType: .internet,
					name: "Comcast",
					monthlyCost: 80,
					accountNumber: "9876543210",
					notes: "Gigabit connection"
				)

				ServiceProvider(
					id: uuid(),
					profileID: profileID,
					providerType: .cell,
					name: "Verizon",
					monthlyCost: 75,
					accountNumber: "5551234567",
					notes: "Unlimited plan"
				)

				// Subscriptions
				Subscription(
					id: uuid(),
					profileID: profileID,
					name: "Netflix",
					category: .streaming,
					monthlyCost: 15.99,
					billingCycle: .monthly,
					renewalDate: now.addingTimeInterval(60 * 60 * 24 * 30), // 1 month from now
					isActive: true,
					notes: "Premium plan"
				)

				Subscription(
					id: uuid(),
					profileID: profileID,
					name: "Spotify",
					category: .music,
					monthlyCost: 9.99,
					billingCycle: .monthly,
					renewalDate: now.addingTimeInterval(60 * 60 * 24 * 30), // 1 month from now
					isActive: true,
					notes: "Individual plan"
				)

				// Insurance policy
				InsurancePolicy(
					id: uuid(),
					profileID: profileID,
					type: .health,
					provider: "Blue Cross",
					policyNumber: "BC123456789",
					monthlyCost: 350,
					deductible: 2000,
					coverageAmount: 1_000_000,
					startDate: now,
					renewalDate: now.addingTimeInterval(60 * 60 * 24 * 365), // 1 year from now
					isActive: true,
					notes: "PPO plan through employer"
				)

				// Device
				Device(
					id: uuid(),
					profileID: profileID,
					type: .computer,
					brand: "Apple",
					model: "MacBook Pro 16\" M3 Max",
					serialNumber: "C02ABC123XYZ",
					purchaseDate: now.addingTimeInterval(-60 * 60 * 24 * 365), // 1 year ago
					notes: "Work computer"
				)
			}

			print("✅ Sample data seeded successfully")
		}
	}
}
