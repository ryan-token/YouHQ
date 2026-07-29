//
//  AppDatabase.swift
//  YouHQ
//
//  Created by Ryan Token on 12/29/25.
//

import Dependencies
import Foundation
import SQLiteData

// swiftlint:disable file_length

func appDatabase(attachMetadatabase shouldAttachMetadatabase: Bool = true) throws -> any DatabaseWriter {
	var configuration = Configuration()
	configuration.foreignKeysEnabled = true
	configuration.prepareDatabase { db in
		if shouldAttachMetadatabase {
			try db.attachMetadatabase()
		}

		// The profile triggers' `WHEN NOT ...` guards call this function; register it on
		// every connection so it resolves even in tests/previews (where it reports `false`).
		db.add(function: SyncEngine.$isSynchronizing)

		#if DEBUG
			@Dependency(\.context) var context
			db.trace(options: .profile) { event in
				let description = event.expandedDescription
				// Skip sync engine queries and internal trigger/comment lines
				guard
					!SyncEngine.isSynchronizing,
					!description.hasPrefix("--"),
					context != .test
				else { return }
				print("[DEBUG] \(description)")
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

	let migrator = youHQMigrator()
	try migrator.migrate(database)
	// After migrating, not before: the `-wal` and `-shm` files only exist once something has
	// been written, and the loop below silently skips files that are not there yet.
	applyDataProtection(to: database.path)
	return database
}

/// Every migration, in order.
///
/// Extracted from `appDatabase()` so tests can migrate to a chosen point, seed rows in the
/// shape that version wrote, and then run a later migration against realistic data. The
/// table rebuild is the one step whose correctness depends on the data already present.
nonisolated func youHQMigrator() -> DatabaseMigrator {
	var migrator = DatabaseMigrator()

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
				"monthlyCost" TEXT,
				"costType" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'Owned (No Payment)',
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

	// MARK: - Encrypt Sensitive Fields

	// This migration used to encrypt sensitive columns in place. The app no longer encrypts
	// fields itself, so it does nothing now, but it has to stay registered: GRDB records
	// applied migrations by identifier, and dropping one it has already seen is an error.
	// `LegacyEncryptedFieldSweep` undoes what this used to do.
	migrator.registerMigration("Encrypt sensitive fields") { _ in }

	// MARK: - App Settings

	migrator.registerMigration("Create app settings table") { db in
		try #sql(
			"""
			CREATE TABLE "appSettings" (
				"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
				"reminderInterval" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'None'
			) STRICT
			"""
		)
		.execute(db)

		// Seed with a default row so code can always assume the row exists
		try #sql(
			"""
			INSERT INTO "appSettings" ("id", "reminderInterval")
			VALUES (uuid(), 'None')
			"""
		)
		.execute(db)
	}

	// MARK: - Currency Support

	migrator.registerMigration("Add currency code columns") { db in
		// Per-record currency override. A `NULL` value means the record follows
		// the app-wide default currency (`AppSettings.currencyCode`), which in
		// turn falls back to the device locale when unset.
		//
		// All columns are nullable with no default so the change is additive and
		// safe for CloudKit sync: older app versions simply ignore the new field.
		try #sql(
			"""
			ALTER TABLE "residences" ADD COLUMN "currencyCode" TEXT
			"""
		)
		.execute(db)

		try #sql(
			"""
			ALTER TABLE "utilities" ADD COLUMN "currencyCode" TEXT
			"""
		)
		.execute(db)

		try #sql(
			"""
			ALTER TABLE "vehicles" ADD COLUMN "currencyCode" TEXT
			"""
		)
		.execute(db)

		try #sql(
			"""
			ALTER TABLE "serviceProviders" ADD COLUMN "currencyCode" TEXT
			"""
		)
		.execute(db)

		try #sql(
			"""
			ALTER TABLE "subscriptions" ADD COLUMN "currencyCode" TEXT
			"""
		)
		.execute(db)

		try #sql(
			"""
			ALTER TABLE "jobs" ADD COLUMN "currencyCode" TEXT
			"""
		)
		.execute(db)

		try #sql(
			"""
			ALTER TABLE "insurancePolicies" ADD COLUMN "currencyCode" TEXT
			"""
		)
		.execute(db)

		try #sql(
			"""
			ALTER TABLE "others" ADD COLUMN "currencyCode" TEXT
			"""
		)
		.execute(db)

		// App-wide default currency. `NULL` means "follow the device locale".
		try #sql(
			"""
			ALTER TABLE "appSettings" ADD COLUMN "currencyCode" TEXT
			"""
		)
		.execute(db)
	}

	// MARK: - Rename Encrypted Salary Column

	migrator.registerMigration("Rename jobs.salary for CloudKit type compatibility") { db in
		// `EncryptedDouble` writes an encrypted string, but the original `salary` CloudKit
		// field is a legacy `DOUBLE` that rejected it. Renaming forces a fresh
		// encrypted-string field; the old `DOUBLE` field is left unused.
		try #sql(
			"""
			ALTER TABLE "jobs" RENAME COLUMN "salary" TO "salaryEncrypted"
			"""
		)
		.execute(db)
	}

	// MARK: - Guard Profile Triggers Against Sync

	migrator.registerMigration("Guard profile triggers against sync writes") { db in
		// Unguarded, these triggers also fired on sync-engine writes, so applying a remote
		// change bumped `profiles.updatedAt` and re-uploaded the profile — an endless loop.
		// Recreate each with a `WHEN NOT <syncing>` guard so they run only for local edits
		// (`ensure_default_profile` too, so a synced delete can't resurrect a profile).

		try #sql(
			"""
			DROP TRIGGER IF EXISTS "ensure_default_profile"
			"""
		)
		.execute(db)
		try #sql(
			"""
			CREATE TRIGGER "ensure_default_profile"
			AFTER DELETE ON "profiles"
			WHEN (SELECT COUNT(*) FROM "profiles") = 0 AND NOT \(SyncEngine.$isSynchronizing)
			BEGIN
				INSERT INTO "profiles" ("name") VALUES ('Default');
			END
			"""
		)
		.execute(db)

		// Tables with a direct `profileID`. The trigger-name infix matches the existing
		// (legacy) names — note `residence` is singular while the table is `residences`.
		let directProfileTables: [(infix: String, table: String)] = [
			("residence", "residences"),
			("bankAccounts", "bankAccounts"),
			("investmentAccounts", "investmentAccounts"),
			("healthSavingsAccounts", "healthSavingsAccounts"),
			("serviceProviders", "serviceProviders"),
			("vehicles", "vehicles"),
			("devices", "devices"),
			("subscriptions", "subscriptions"),
			("jobs", "jobs"),
			("insurancePolicies", "insurancePolicies"),
			("others", "others"),
			("assets", "assets")
		]

		for (infix, table) in directProfileTables {
			for event in ["insert", "update", "delete"] {
				try #sql(
					"""
					DROP TRIGGER IF EXISTS "update_profile_on_\(raw: infix)_\(raw: event)"
					"""
				)
				.execute(db)
			}
			try #sql(
				"""
				CREATE TRIGGER "update_profile_on_\(raw: infix)_insert"
				AFTER INSERT ON "\(raw: table)"
				WHEN NOT \(SyncEngine.$isSynchronizing)
				BEGIN
					UPDATE "profiles" SET "updatedAt" = datetime('now') WHERE "id" = NEW."profileID";
				END
				"""
			)
			.execute(db)
			try #sql(
				"""
				CREATE TRIGGER "update_profile_on_\(raw: infix)_update"
				AFTER UPDATE ON "\(raw: table)"
				WHEN NOT \(SyncEngine.$isSynchronizing)
				BEGIN
					UPDATE "profiles" SET "updatedAt" = datetime('now') WHERE "id" = NEW."profileID";
				END
				"""
			)
			.execute(db)
			try #sql(
				"""
				CREATE TRIGGER "update_profile_on_\(raw: infix)_delete"
				AFTER DELETE ON "\(raw: table)"
				WHEN NOT \(SyncEngine.$isSynchronizing)
				BEGIN
					UPDATE "profiles" SET "updatedAt" = datetime('now') WHERE "id" = OLD."profileID";
				END
				"""
			)
			.execute(db)
		}

		// paintColors and maintenanceItems resolve `profileID` through their residence or
		// vehicle parent.
		for table in ["paintColors", "maintenanceItems"] {
			for event in ["insert", "update", "delete"] {
				try #sql(
					"""
					DROP TRIGGER IF EXISTS "update_profile_on_\(raw: table)_\(raw: event)"
					"""
				)
				.execute(db)
			}
			try #sql(
				"""
				CREATE TRIGGER "update_profile_on_\(raw: table)_insert"
				AFTER INSERT ON "\(raw: table)"
				WHEN NOT \(SyncEngine.$isSynchronizing)
				BEGIN
					UPDATE "profiles" SET "updatedAt" = datetime('now')
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
				CREATE TRIGGER "update_profile_on_\(raw: table)_update"
				AFTER UPDATE ON "\(raw: table)"
				WHEN NOT \(SyncEngine.$isSynchronizing)
				BEGIN
					UPDATE "profiles" SET "updatedAt" = datetime('now')
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
				CREATE TRIGGER "update_profile_on_\(raw: table)_delete"
				AFTER DELETE ON "\(raw: table)"
				WHEN NOT \(SyncEngine.$isSynchronizing)
				BEGIN
					UPDATE "profiles" SET "updatedAt" = datetime('now')
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

		// utilities resolves `profileID` through its residence parent.
		for event in ["insert", "update", "delete"] {
			try #sql(
				"""
				DROP TRIGGER IF EXISTS "update_profile_on_utilities_\(raw: event)"
				"""
			)
			.execute(db)
		}
		try #sql(
			"""
			CREATE TRIGGER "update_profile_on_utilities_insert"
			AFTER INSERT ON "utilities"
			WHEN NOT \(SyncEngine.$isSynchronizing)
			BEGIN
				UPDATE "profiles" SET "updatedAt" = datetime('now')
				WHERE "id" = (SELECT "profileID" FROM "residences" WHERE "id" = NEW."residenceID");
			END
			"""
		)
		.execute(db)
		try #sql(
			"""
			CREATE TRIGGER "update_profile_on_utilities_update"
			AFTER UPDATE ON "utilities"
			WHEN NOT \(SyncEngine.$isSynchronizing)
			BEGIN
				UPDATE "profiles" SET "updatedAt" = datetime('now')
				WHERE "id" = (SELECT "profileID" FROM "residences" WHERE "id" = NEW."residenceID");
			END
			"""
		)
		.execute(db)
		try #sql(
			"""
			CREATE TRIGGER "update_profile_on_utilities_delete"
			AFTER DELETE ON "utilities"
			WHEN NOT \(SyncEngine.$isSynchronizing)
			BEGIN
				UPDATE "profiles" SET "updatedAt" = datetime('now')
				WHERE "id" = (SELECT "profileID" FROM "residences" WHERE "id" = OLD."residenceID");
			END
			"""
		)
		.execute(db)
	}

	// MARK: - Plaintext Salary Column

	migrator.registerMigration("Add plaintext salary column") { db in
		// Salaries are no longer encrypted, and neither existing column can hold a plain
		// number: `salary` is a deployed CloudKit `DOUBLE` and `salaryEncrypted` a deployed
		// `STRING`. `salaryEncrypted` stays behind rather than being dropped, so
		// `LegacyEncryptedFieldSweep` still has something to decrypt and so devices on an
		// older version keep showing a salary until they update.
		try #sql(
			"""
			ALTER TABLE "jobs" ADD COLUMN "salaryAmount" REAL
			"""
		)
		.execute(db)
	}

	// MARK: - Single Profile Foreign Key

	migrator.registerMigration("Reduce shared child tables to a single profile foreign key") { db in
		try reduceToSingleProfileForeignKey(db)
	}

	return migrator
}

// MARK: - Single Profile Foreign Key

/// Every table whose only foreign key must be `profileID`.
///
/// SQLiteData assigns a CloudKit parent only to a table with exactly one foreign key, and a
/// record with no parent is a root record that no share ever includes. These five had more, so
/// none of their records reached the people a profile was shared with.
nonisolated let singleProfileForeignKeyTables = [
	"insurancePolicies", "others", "maintenanceItems", "paintColors", "assets"
]

enum SchemaRebuildError: Error {
	case foreignKeysEnabled
	case rowsLost(table: String, before: Int, after: Int)
}

/// Rebuilds the five tables so `profileID` is their only foreign key, keeping `residenceID`,
/// `vehicleID` and the rest as plain columns so every query and screen is unaffected.
private nonisolated func reduceToSingleProfileForeignKey(_ db: Database) throws {
	// GRDB's default `.deferred` migration turns foreign keys off for the duration and checks
	// the whole database before committing. That is load bearing rather than incidental: with
	// them on, `DROP TABLE` performs an implicit delete that cascades, so rebuilding
	// `maintenanceItems` would take every photo attached to one and all completion history
	// with it, silently and before the sync engine exists to record any of it.
	guard try Int.fetchOne(db, sql: "PRAGMA foreign_keys") == 0 else {
		throw SchemaRebuildError.foreignKeysEnabled
	}

	let assetsBefore = try rowCount(of: "assets", db)
	let completionsBefore = try rowCount(of: "maintenanceCompletions", db)

	// Indexes and triggers belong to the table and are dropped with it. Replaying the SQL
	// SQLite already recorded restores all 19 indexes and 15 triggers exactly as they shipped,
	// including the `WHEN NOT sqlitedata_icloud_isSynchronizing()` guards that keep profile
	// timestamp bumps from looping during sync.
	let recordedObjects = try String.fetchAll(
		db,
		sql: """
			SELECT "sql" FROM "sqlite_master"
			WHERE "type" IN ('index', 'trigger')
			AND "tbl_name" IN ('insurancePolicies', 'others', 'maintenanceItems', 'paintColors', 'assets')
			AND "sql" IS NOT NULL
			"""
	)

	try rebuildInsurancePolicies(db)
	try rebuildOthers(db)
	try rebuildMaintenanceItems(db)
	try rebuildPaintColors(db)
	try rebuildAssets(db)

	// Only rows whose own residence or vehicle names a profile. Never a device-wide "current
	// profile": multiple profiles ship, and a share recipient holds the owner's profile
	// alongside their own, so a global fallback would file the owner's records under a
	// stranger's profile and sync them into the wrong iCloud account.
	for table in ["maintenanceItems", "paintColors"] {
		try #sql(
			"""
			UPDATE "\(raw: table)" SET "profileID" = COALESCE(
				(SELECT "profileID" FROM "residences" WHERE "id" = "\(raw: table)"."residenceID"),
				(SELECT "profileID" FROM "vehicles" WHERE "id" = "\(raw: table)"."vehicleID")
			)
			"""
		)
		.execute(db)
	}

	for sql in recordedObjects {
		try db.execute(sql: sql)
	}
	for table in ["maintenanceItems", "paintColors"] {
		try #sql(
			"""
			CREATE INDEX "idx_\(raw: table)_profileID" ON "\(raw: table)"("profileID")
			"""
		)
		.execute(db)
	}

	try createParentDeletionTriggers(db)
	try createProfileBackfillTriggers(db)

	let assetsAfter = try rowCount(of: "assets", db)
	let completionsAfter = try rowCount(of: "maintenanceCompletions", db)
	guard assetsAfter == assetsBefore else {
		throw SchemaRebuildError.rowsLost(table: "assets", before: assetsBefore, after: assetsAfter)
	}
	guard completionsAfter == completionsBefore else {
		throw SchemaRebuildError.rowsLost(
			table: "maintenanceCompletions",
			before: completionsBefore,
			after: completionsAfter
		)
	}
}

private nonisolated func rowCount(of table: String, _ db: Database) throws -> Int {
	try Int.fetchOne(db, sql: "SELECT count(*) FROM \"\(table)\"") ?? 0
}

/// Copies every row into the rebuilt table and swaps it into place.
///
/// Only the new table is ever renamed. Renaming the original aside would have SQLite rewrite
/// the `REFERENCES` clauses in `assets` and `maintenanceCompletions` to follow it, leaving them
/// pointing at a table about to be dropped. `SyncEngine` refuses to start on a dangling foreign
/// key, and it starts inside `try!`, so that mistake would be an unrecoverable launch crash.
///
/// Columns are named rather than copied positionally: `currencyCode` was appended by a later
/// `ALTER TABLE`, so live column order does not match the original `CREATE TABLE`, and every
/// column involved is `TEXT`, which means a shifted copy would not trip `STRICT`.
private nonisolated func swapInRebuiltTable(
	_ table: String,
	columns: [String],
	_ db: Database
) throws {
	let columnList = (["rowid"] + columns).map { "\"\($0)\"" }.joined(separator: ", ")
	try #sql(
		"""
		INSERT INTO "new_\(raw: table)" (\(raw: columnList))
		SELECT \(raw: columnList) FROM "\(raw: table)" ORDER BY "rowid"
		"""
	)
	.execute(db)
	try #sql(
		"""
		DROP TABLE "\(raw: table)"
		"""
	)
	.execute(db)
	try #sql(
		"""
		ALTER TABLE "new_\(raw: table)" RENAME TO "\(raw: table)"
		"""
	)
	.execute(db)
}

private nonisolated func rebuildInsurancePolicies(_ db: Database) throws {
	try #sql(
		"""
		CREATE TABLE "new_insurancePolicies" (
			"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
			"profileID" TEXT NOT NULL REFERENCES "profiles"("id") ON DELETE CASCADE,
			"residenceID" TEXT,
			"vehicleID" TEXT,
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
			"currencyCode" TEXT,
			CHECK (
				("type" IN ('Home', 'Renters') AND "residenceID" IS NOT NULL AND "vehicleID" IS NULL) OR
				("type" = 'Auto' AND "vehicleID" IS NOT NULL AND "residenceID" IS NULL) OR
				("type" NOT IN ('Home', 'Renters', 'Auto') AND "residenceID" IS NULL AND "vehicleID" IS NULL)
			)
		) STRICT
		"""
	)
	.execute(db)
	try swapInRebuiltTable(
		"insurancePolicies",
		columns: [
			"id", "profileID", "residenceID", "vehicleID", "type", "provider", "policyNumber",
			"monthlyCost", "deductible", "coverageAmount", "startDate", "renewalDate", "isActive",
			"backgroundColor", "url", "notes", "currencyCode"
		],
		db
	)
}

private nonisolated func rebuildOthers(_ db: Database) throws {
	try #sql(
		"""
		CREATE TABLE "new_others" (
			"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
			"profileID" TEXT NOT NULL REFERENCES "profiles"("id") ON DELETE CASCADE,
			"residenceID" TEXT,
			"vehicleID" TEXT,
			"category" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'Homes',
			"name" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
			"otherDescription" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
			"monthlyCost" TEXT,
			"backgroundColor" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'gray',
			"url" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
			"notes" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
			"currencyCode" TEXT,
			CHECK (
				("category" = 'Homes' AND "residenceID" IS NOT NULL AND "vehicleID" IS NULL) OR
				("category" = 'Vehicles' AND "vehicleID" IS NOT NULL AND "residenceID" IS NULL) OR
				("category" IN ('Money', 'Media', 'Career') AND "residenceID" IS NULL AND "vehicleID" IS NULL)
			)
		) STRICT
		"""
	)
	.execute(db)
	try swapInRebuiltTable(
		"others",
		columns: [
			"id", "profileID", "residenceID", "vehicleID", "category", "name", "otherDescription",
			"monthlyCost", "backgroundColor", "url", "notes", "currencyCode"
		],
		db
	)
}

private nonisolated func rebuildMaintenanceItems(_ db: Database) throws {
	try #sql(
		"""
		CREATE TABLE "new_maintenanceItems" (
			"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
			"profileID" TEXT REFERENCES "profiles"("id") ON DELETE CASCADE,
			"residenceID" TEXT,
			"vehicleID" TEXT,
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
	try swapInRebuiltTable(
		"maintenanceItems",
		columns: [
			"id", "residenceID", "vehicleID", "name", "itemDescription", "intervalType",
			"intervalValue", "lastCompletedAt", "dueDate", "shouldNotify", "notificationIdentifier",
			"backgroundColor", "url", "notes"
		],
		db
	)
}

private nonisolated func rebuildPaintColors(_ db: Database) throws {
	try #sql(
		"""
		CREATE TABLE "new_paintColors" (
			"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
			"profileID" TEXT REFERENCES "profiles"("id") ON DELETE CASCADE,
			"residenceID" TEXT,
			"vehicleID" TEXT,
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
	try swapInRebuiltTable(
		"paintColors",
		columns: [
			"id", "residenceID", "vehicleID", "manufacturer", "colorName", "colorCode", "room",
			"finish", "purchaseDate", "surfaceType", "storePurchasedFrom", "applicationDate",
			"backgroundColor", "url", "notes"
		],
		db
	)
}

private nonisolated func rebuildAssets(_ db: Database) throws {
	try #sql(
		"""
		CREATE TABLE "new_assets" (
			"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
			"profileID" TEXT NOT NULL REFERENCES "profiles"("id") ON DELETE CASCADE,
			"residenceID" TEXT,
			"vehicleID" TEXT,
			"insurancePolicyID" TEXT,
			"maintenanceItemID" TEXT,
			"deviceID" TEXT,
			"otherID" TEXT,
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
	try swapInRebuiltTable(
		"assets",
		columns: [
			"id", "profileID", "residenceID", "vehicleID", "insurancePolicyID", "maintenanceItemID",
			"deviceID", "otherID", "imageData"
		],
		db
	)
}

/// Fills in `profileID` for maintenance items and paint colors created without one.
///
/// The screens that create these hold a residence or a vehicle, not a profile, so resolving it
/// here keeps every creation path share-correct without threading a profile through them.
///
/// Guarded against sync writes, matching the profile timestamp triggers: a row arriving from a
/// client on an older version has no `profileID`, and `ShareParentSweep` adopts it on the next
/// launch rather than this trigger writing during sync.
private nonisolated func createProfileBackfillTriggers(_ db: Database) throws {
	for table in ["maintenanceItems", "paintColors"] {
		try #sql(
			"""
			CREATE TRIGGER "backfill_profile_on_\(raw: table)_insert"
			AFTER INSERT ON "\(raw: table)"
			FOR EACH ROW
			WHEN NEW."profileID" IS NULL AND NOT \(SyncEngine.$isSynchronizing)
			BEGIN
				UPDATE "\(raw: table)" SET "profileID" = COALESCE(
					(SELECT "profileID" FROM "residences" WHERE "id" = NEW."residenceID"),
					(SELECT "profileID" FROM "vehicles" WHERE "id" = NEW."vehicleID")
				)
				WHERE "id" = NEW."id";
			END
			"""
		)
		.execute(db)
	}
}

/// Recreates, as triggers, the deletes that the removed foreign keys used to cascade.
///
/// Deliberately not guarded with `NOT sqlitedata_icloud_isSynchronizing()`, unlike the profile
/// timestamp triggers. A foreign key cascade ran for remote deletes as well as local ones, and
/// these have to keep doing that or a deletion synced from another device leaves orphans
/// behind. The guard exists to stop triggers that *write* data from looping during sync;
/// propagating a delete does not loop.
/// The tables that hang off a residence or a vehicle and lost their cascade with the foreign key.
private nonisolated let childTablesOfPlace = [
	"insurancePolicies", "others", "maintenanceItems", "paintColors", "assets"
]

private nonisolated struct ParentDeletion {
	let parent: String
	let childColumn: String
	let children: [String]
}

private nonisolated func createParentDeletionTriggers(_ db: Database) throws {
	let childrenByParent: [ParentDeletion] = [
		ParentDeletion(parent: "residences", childColumn: "residenceID", children: childTablesOfPlace),
		ParentDeletion(parent: "vehicles", childColumn: "vehicleID", children: childTablesOfPlace),
		ParentDeletion(parent: "insurancePolicies", childColumn: "insurancePolicyID", children: ["assets"]),
		ParentDeletion(parent: "maintenanceItems", childColumn: "maintenanceItemID", children: ["assets"]),
		ParentDeletion(parent: "devices", childColumn: "deviceID", children: ["assets"]),
		ParentDeletion(parent: "others", childColumn: "otherID", children: ["assets"])
	]

	for deletion in childrenByParent {
		var statements: [String] = []
		for child in deletion.children {
			statements.append(#"DELETE FROM "\#(child)" WHERE "\#(deletion.childColumn)" = OLD."id";"#)
		}
		let parent = deletion.parent
		let deletes = statements.joined(separator: "\n\t")
		try #sql(
			"""
			CREATE TRIGGER "delete_children_of_\(raw: parent)"
			AFTER DELETE ON "\(raw: parent)"
			FOR EACH ROW
			BEGIN
				\(raw: deletes)
			END
			"""
		)
		.execute(db)
	}
}

// MARK: - Data Protection

/// Marks the database and its write-ahead log as encrypted at rest until the device has
/// been unlocked once after a restart.
///
/// This is the same class the app container already gives its files, so it changes no
/// behavior. It is written down because the guarantee matters: sensitive fields are no
/// longer encrypted by the app itself, and this is what protects them on disk.
///
/// A stronger class is deliberately not used. `.complete` and `.completeUnlessOpen` make a
/// file unreadable whenever the device is locked, and CloudKit wakes the app to sync while
/// it is locked, which would turn every background sync into a failure.
private nonisolated func applyDataProtection(to path: String) {
	#if !os(macOS)
		// Plain string paths, not a URL round-trip: `URL.path()` percent-encodes, and the
		// database lives under "Application Support", so the encoded path never matches a
		// real file and every attribute write would be silently skipped.
		for filePath in [path, path + "-wal", path + "-shm"]
		where FileManager.default.fileExists(atPath: filePath) {
			withErrorReporting {
				try FileManager.default.setAttributes(
					[.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
					ofItemAtPath: filePath
				)
			}
		}
	#endif
}

// MARK: - Bootstrap

extension DependencyValues {
	mutating func bootstrapDatabase() throws {
		defaultDatabase = try appDatabase(attachMetadatabase: context != .test)
	}
}
