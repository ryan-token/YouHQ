//
//  AppDatabase.swift
//  YouHQ
//
//  Created by Ryan Token on 12/29/25.
//

import SQLiteData

// swiftlint:disable file_length

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
				"backgroundColor" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'indigo',
				"url" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
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
				"backgroundColor" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'blue',
				"url" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"notes" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT ''
			) STRICT
			"""
		)
		.execute(db)

		// Vehicle table
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
				"backgroundColor" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'teal',
				"url" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
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
				"backgroundColor" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'green',
				"url" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
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
				"backgroundColor" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'mint',
				"url" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
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
				"backgroundColor" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'cyan',
				"url" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
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
				"backgroundColor" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'purple',
				"url" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
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
				"backgroundColor" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'pink',
				"url" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
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
				"backgroundColor" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'orange',
				"url" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
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
				"backgroundColor" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'blue',
				"url" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
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
				"residenceID" TEXT REFERENCES "residences"("id") ON DELETE CASCADE,
				"vehicleID" TEXT REFERENCES "vehicles"("id") ON DELETE CASCADE,
				"type" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'health',
				"provider" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"policyNumber" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"monthlyCost" TEXT,
				"deductible" TEXT,
				"coverageAmount" TEXT,
				"startDate" TEXT,
				"renewalDate" TEXT,
				"isActive" INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 1,
				"backgroundColor" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'red',
				"url" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"notes" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				CHECK (
					("type" IN ('Home', 'Renters') AND "residenceID" IS NOT NULL AND "vehicleID" IS NULL) OR
					("type" = 'Auto' AND "vehicleID" IS NOT NULL AND "residenceID" IS NULL) OR
					("type" NOT IN ('Home', 'Renters', 'Auto') AND "residenceID" IS NULL AND "vehicleID" IS NULL)
				)
			) STRICT
			"""
		)
		.execute(db)

		// Other table
		try #sql(
			"""
			CREATE TABLE "others" (
				"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
				"profileID" TEXT NOT NULL REFERENCES "profiles"("id") ON DELETE CASCADE,
				"residenceID" TEXT REFERENCES "residences"("id") ON DELETE CASCADE,
				"vehicleID" TEXT REFERENCES "vehicles"("id") ON DELETE CASCADE,
				"category" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'Homes',
				"name" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"otherDescription" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"monthlyCost" TEXT,
				"backgroundColor" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'gray',
				"url" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"notes" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				CHECK (
					("category" = 'Homes' AND "residenceID" IS NOT NULL AND "vehicleID" IS NULL) OR
					("category" = 'Vehicles' AND "vehicleID" IS NOT NULL AND "residenceID" IS NULL) OR
					("category" IN ('Money', 'Media', 'Career') AND "residenceID" IS NULL AND "vehicleID" IS NULL)
				)
			) STRICT
			"""
		)
		.execute(db)

		// Maintenance Item table
		try #sql(
			"""
			CREATE TABLE "maintenanceItems" (
				"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
				"residenceID" TEXT REFERENCES "residences"("id") ON DELETE CASCADE,
				"vehicleID" TEXT REFERENCES "vehicles"("id") ON DELETE CASCADE,
				"name" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"itemDescription" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"intervalType" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'month',
				"intervalValue" INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 1,
				"lastCompletedAt" TEXT,
				"dueDate" TEXT,
				"shouldNotify" INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
				"notificationIdentifier" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"backgroundColor" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'yellow',
				"url" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"notes" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				CHECK (
					("residenceID" IS NOT NULL AND "vehicleID" IS NULL) OR
					("residenceID" IS NULL AND "vehicleID" IS NOT NULL)
				)
			) STRICT
			"""
		)
		.execute(db)

		// Asset table
		try #sql(
			"""
			CREATE TABLE "assets" (
				"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
				"profileID" TEXT NOT NULL REFERENCES "profiles"("id") ON DELETE CASCADE,
				"residenceID" TEXT REFERENCES "residences"("id") ON DELETE CASCADE,
				"vehicleID" TEXT REFERENCES "vehicles"("id") ON DELETE CASCADE,
				"insurancePolicyID" TEXT REFERENCES "insurancePolicies"("id") ON DELETE CASCADE,
				"maintenanceItemID" TEXT REFERENCES "maintenanceItems"("id") ON DELETE CASCADE,
				"deviceID" TEXT REFERENCES "devices"("id") ON DELETE CASCADE,
				"otherID" TEXT REFERENCES "others"("id") ON DELETE CASCADE,
				"imageData" BLOB NOT NULL,
				CHECK (
					("residenceID" IS NOT NULL) +
					("vehicleID" IS NOT NULL) +
					("insurancePolicyID" IS NOT NULL) +
					("maintenanceItemID" IS NOT NULL) +
					("deviceID" IS NOT NULL) +
					("otherID" IS NOT NULL)
					= 1
				)
			) STRICT
			"""
		)
		.execute(db)

		// Maintenance Completion table
		try #sql(
			"""
			CREATE TABLE "maintenanceCompletions" (
				"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
				"maintenanceItemID" TEXT NOT NULL REFERENCES "maintenanceItems"("id") ON DELETE CASCADE,
				"completedAt" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT (datetime('now')),
				"notes" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT ''
			) STRICT
			"""
		)
		.execute(db)

		// Paint Color table
		try #sql(
			"""
			CREATE TABLE "paintColors" (
				"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
				"residenceID" TEXT REFERENCES "residences"("id") ON DELETE CASCADE,
				"vehicleID" TEXT REFERENCES "vehicles"("id") ON DELETE CASCADE,
				"manufacturer" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"colorName" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"colorCode" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"room" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"finish" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'Eggshell',
				"purchaseDate" TEXT,
				"surfaceType" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"storePurchasedFrom" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"applicationDate" TEXT,
				"backgroundColor" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'purple',
				"url" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				"notes" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
				CHECK (
					("residenceID" IS NOT NULL AND "vehicleID" IS NULL) OR
					("residenceID" IS NULL AND "vehicleID" IS NOT NULL)
				)
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

		try #sql(
			"""
			CREATE INDEX "idx_insurancePolicies_residenceID" ON "insurancePolicies"("residenceID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_insurancePolicies_vehicleID" ON "insurancePolicies"("vehicleID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_others_profileID" ON "others"("profileID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_others_residenceID" ON "others"("residenceID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_others_vehicleID" ON "others"("vehicleID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_others_category" ON "others"("category")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_maintenanceItems_residenceID" ON "maintenanceItems"("residenceID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_maintenanceItems_vehicleID" ON "maintenanceItems"("vehicleID")
			"""
		)
		.execute(db)
		try #sql(
			"""
			CREATE INDEX "idx_assets_profileID" ON "assets"("profileID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_assets_residenceID" ON "assets"("residenceID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_assets_vehicleID" ON "assets"("vehicleID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_assets_insurancePolicyID" ON "assets"("insurancePolicyID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_assets_maintenanceItemID" ON "assets"("maintenanceItemID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_assets_deviceID" ON "assets"("deviceID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_assets_otherID" ON "assets"("otherID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_maintenanceCompletions_maintenanceItemID" ON "maintenanceCompletions"("maintenanceItemID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_paintColors_residenceID" ON "paintColors"("residenceID")
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE INDEX "idx_paintColors_vehicleID" ON "paintColors"("vehicleID")
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

		// Create triggers for tables with direct profileID
		let tables = [
			"bankAccounts",
			"investmentAccounts",
			"healthSavingsAccounts",
			"serviceProviders",
			"vehicles",
			"devices",
			"subscriptions",
			"jobs",
			"insurancePolicies",
			"others",
			"assets"
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

		// Create triggers for paintColors (references profileID through residences or vehicles)
		try #sql(
			"""
			CREATE TRIGGER "update_profile_on_paintColors_insert"
			AFTER INSERT ON "paintColors"
			BEGIN
				UPDATE "profiles"
				SET "updatedAt" = datetime('now')
				WHERE "id" IN (
					SELECT "profileID" FROM "residences" WHERE "id" = NEW."residenceID"
					UNION
					SELECT "profileID" FROM "vehicles" WHERE "id" = NEW."vehicleID"
				);
			END
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE TRIGGER "update_profile_on_paintColors_update"
			AFTER UPDATE ON "paintColors"
			BEGIN
				UPDATE "profiles"
				SET "updatedAt" = datetime('now')
				WHERE "id" IN (
					SELECT "profileID" FROM "residences" WHERE "id" = NEW."residenceID"
					UNION
					SELECT "profileID" FROM "vehicles" WHERE "id" = NEW."vehicleID"
				);
			END
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE TRIGGER "update_profile_on_paintColors_delete"
			AFTER DELETE ON "paintColors"
			BEGIN
				UPDATE "profiles"
				SET "updatedAt" = datetime('now')
				WHERE "id" IN (
					SELECT "profileID" FROM "residences" WHERE "id" = OLD."residenceID"
					UNION
					SELECT "profileID" FROM "vehicles" WHERE "id" = OLD."vehicleID"
				);
			END
			"""
		)
		.execute(db)

		// Create triggers for utilities (references profileID through residences)
		try #sql(
			"""
			CREATE TRIGGER "update_profile_on_utilities_insert"
			AFTER INSERT ON "utilities"
			BEGIN
				UPDATE "profiles"
				SET "updatedAt" = datetime('now')
				WHERE "id" = (SELECT "profileID" FROM "residences" WHERE "id" = NEW."residenceID");
			END
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE TRIGGER "update_profile_on_utilities_update"
			AFTER UPDATE ON "utilities"
			BEGIN
				UPDATE "profiles"
				SET "updatedAt" = datetime('now')
				WHERE "id" = (SELECT "profileID" FROM "residences" WHERE "id" = NEW."residenceID");
			END
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE TRIGGER "update_profile_on_utilities_delete"
			AFTER DELETE ON "utilities"
			BEGIN
				UPDATE "profiles"
				SET "updatedAt" = datetime('now')
				WHERE "id" = (SELECT "profileID" FROM "residences" WHERE "id" = OLD."residenceID");
			END
			"""
		)
		.execute(db)

		// Create triggers for maintenanceItems (references profileID through residences or vehicles)
		try #sql(
			"""
			CREATE TRIGGER "update_profile_on_maintenanceItems_insert"
			AFTER INSERT ON "maintenanceItems"
			BEGIN
				UPDATE "profiles"
				SET "updatedAt" = datetime('now')
				WHERE "id" IN (
					SELECT "profileID" FROM "residences" WHERE "id" = NEW."residenceID"
					UNION
					SELECT "profileID" FROM "vehicles" WHERE "id" = NEW."vehicleID"
				);
			END
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE TRIGGER "update_profile_on_maintenanceItems_update"
			AFTER UPDATE ON "maintenanceItems"
			BEGIN
				UPDATE "profiles"
				SET "updatedAt" = datetime('now')
				WHERE "id" IN (
					SELECT "profileID" FROM "residences" WHERE "id" = NEW."residenceID"
					UNION
					SELECT "profileID" FROM "vehicles" WHERE "id" = NEW."vehicleID"
				);
			END
			"""
		)
		.execute(db)

		try #sql(
			"""
			CREATE TRIGGER "update_profile_on_maintenanceItems_delete"
			AFTER DELETE ON "maintenanceItems"
			BEGIN
				UPDATE "profiles"
				SET "updatedAt" = datetime('now')
				WHERE "id" IN (
					SELECT "profileID" FROM "residences" WHERE "id" = OLD."residenceID"
					UNION
					SELECT "profileID" FROM "vehicles" WHERE "id" = OLD."vehicleID"
				);
			END
			"""
		)
		.execute(db)
	}

	try migrator.migrate(database)
	return database
}

// MARK: - Bootstrap

extension DependencyValues {
	mutating func bootstrapDatabase() throws {
		defaultDatabase = try appDatabase()
	}
}
