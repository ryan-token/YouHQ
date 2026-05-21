//
//  DatabaseTests.swift
//  YouHQTests
//
//  Created by Ryan Token on 2/21/26.
//

import Dependencies
import DependenciesTestSupport
import Foundation
import SQLiteData
import Testing

@testable import YouHQ

extension YouHQTests {
	@Suite("Database")
	struct DatabaseTests {

		@Suite("Schema integrity")
		struct SchemaIntegrity {
			@Dependency(\.defaultDatabase) var database

			@Test("All tables can be written to and read from")
			func allTablesWritable() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						Utility.Draft(id: UUID(-3), residenceID: UUID(-2))
						Vehicle.Draft(id: UUID(-4), profileID: UUID(-1), make: "Toyota")
						BankAccount.Draft(id: UUID(-5), profileID: UUID(-1), bankName: "Chase")
						InvestmentAccount.Draft(id: UUID(-6), profileID: UUID(-1), institution: "Vanguard")
						HealthSavingsAccount.Draft(id: UUID(-7), profileID: UUID(-1), accountType: .hsa, institution: "Optum")
						ServiceProvider.Draft(id: UUID(-8), profileID: UUID(-1), providerType: .internet, name: "Comcast")
						Device.Draft(id: UUID(-9), profileID: UUID(-1), type: .computer, brand: "Apple")
						Subscription.Draft(id: UUID(-10), profileID: UUID(-1), name: "Netflix")
						Job.Draft(id: UUID(-11), profileID: UUID(-1), company: "Acme")
						InsurancePolicy.Draft(id: UUID(-12), profileID: UUID(-1), type: .health)
						Other.Draft(id: UUID(-13), profileID: UUID(-1), residenceID: UUID(-2), category: .homes, name: "Pool")
						MaintenanceItem.Draft(id: UUID(-14), residenceID: UUID(-2), vehicleID: nil, name: "Filter")
						MaintenanceCompletion.Draft(id: UUID(-15), maintenanceItemID: UUID(-14), completedAt: Date())
						PaintColor.Draft(id: UUID(-16), residenceID: UUID(-2), vehicleID: nil, manufacturer: "SW", colorName: "White")
					}
				}

				let profileCount = try await database.read { db in try Profile.fetchCount(db) }
				let residenceCount = try await database.read { db in try Residence.fetchCount(db) }
				let utilityCount = try await database.read { db in try Utility.fetchCount(db) }
				let vehicleCount = try await database.read { db in try Vehicle.fetchCount(db) }
				let bankCount = try await database.read { db in try BankAccount.fetchCount(db) }
				let investCount = try await database.read { db in try InvestmentAccount.fetchCount(db) }
				let hsaCount = try await database.read { db in try HealthSavingsAccount.fetchCount(db) }
				let spCount = try await database.read { db in try ServiceProvider.fetchCount(db) }
				let deviceCount = try await database.read { db in try Device.fetchCount(db) }
				let subCount = try await database.read { db in try Subscription.fetchCount(db) }
				let jobCount = try await database.read { db in try Job.fetchCount(db) }
				let insuranceCount = try await database.read { db in try InsurancePolicy.fetchCount(db) }
				let otherCount = try await database.read { db in try Other.fetchCount(db) }
				let maintenanceCount = try await database.read { db in try MaintenanceItem.fetchCount(db) }
				let completionCount = try await database.read { db in try MaintenanceCompletion.fetchCount(db) }
				let paintCount = try await database.read { db in try PaintColor.fetchCount(db) }

				#expect(profileCount == 1)
				#expect(residenceCount == 1)
				#expect(utilityCount == 1)
				#expect(vehicleCount == 1)
				#expect(bankCount == 1)
				#expect(investCount == 1)
				#expect(hsaCount == 1)
				#expect(spCount == 1)
				#expect(deviceCount == 1)
				#expect(subCount == 1)
				#expect(jobCount == 1)
				#expect(insuranceCount == 1)
				#expect(otherCount == 1)
				#expect(maintenanceCount == 1)
				#expect(completionCount == 1)
				#expect(paintCount == 1)
			}

			@Test("Foreign key constraints are enforced")
			func foreignKeyConstraints() async throws {
				// Attempting to insert a residence for a non-existent profile should fail
				#expect(throws: Error.self) {
					try database.write { db in
						try Residence.insert {
							Residence.Draft(id: UUID(-1), profileID: UUID(-99), street: "Orphan")
						}.execute(db)
					}
				}
			}
		}

		// MARK: - Trigger Tests

		@Suite("Triggers")
		struct Triggers {
			@Dependency(\.defaultDatabase) var database

			@Test("Deleting all profiles triggers creation of a default profile")
			func ensureDefaultProfile() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "OnlyProfile", createdAt: Date(), updatedAt: Date())
					}
				}

				try await database.write { db in
					try Profile.find(UUID(-1)).delete().execute(db)
				}

				// The trigger should have created a new default profile
				let profiles = try await database.read { db in
					try Profile.fetchAll(db)
				}
				#expect(profiles.count == 1)
				let defaultProfile = try #require(profiles.first)
				#expect(defaultProfile.name == "Default")
			}

			@Test("Inserting a residence updates profile updatedAt timestamp")
			func residenceInsertUpdatesProfile() async throws {
				let originalDate = Date(timeIntervalSince1970: 1_000_000)
				try await database.write { db in
					try db.seed {
						Profile.Draft(
							id: UUID(-1), name: "Test",
							createdAt: originalDate, updatedAt: originalDate
						)
					}
				}

				// Small delay to ensure different timestamp
				try await database.write { db in
					try Residence.insert {
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "New Home")
					}.execute(db)
				}

				let profile = try await database.read { db in
					try Profile.find(UUID(-1)).fetchOne(db)
				}
				let updated = try #require(profile)
				#expect(updated.updatedAt > originalDate)
			}

			@Test("Inserting a job updates profile updatedAt timestamp")
			func jobInsertUpdatesProfile() async throws {
				let originalDate = Date(timeIntervalSince1970: 1_000_000)
				try await database.write { db in
					try db.seed {
						Profile.Draft(
							id: UUID(-1), name: "Test",
							createdAt: originalDate, updatedAt: originalDate
						)
					}
				}

				try await database.write { db in
					try Job.insert {
						Job.Draft(id: UUID(-2), profileID: UUID(-1), company: "NewCo")
					}.execute(db)
				}

				let profile = try await database.read { db in
					try Profile.find(UUID(-1)).fetchOne(db)
				}
				let updated = try #require(profile)
				#expect(updated.updatedAt > originalDate)
			}
		}

		// MARK: - MaintenanceIntervalType Tests

		@Suite("Maintenance interval type")
		struct MaintenanceIntervalTypeTests {
			@Test(
				"Calendar component maps correctly",
				arguments: zip(
					[MaintenanceIntervalType.day, .week, .month, .year],
					[Calendar.Component.day, .weekOfYear, .month, .year]
				)
			)
			func calendarComponentMapping(type: MaintenanceIntervalType, expected: Calendar.Component) {
				#expect(type.calendarComponent == expected)
			}
		}

		// MARK: - Cascade Schema Canary

		/// Sanity check that `ON DELETE CASCADE` is wired up on the Profile foreign keys for the
		/// main child tables. Catches a future migration that accidentally drops CASCADE.
		@Suite("Profile cascade canary")
		struct ProfileCascadeCanary {
			@Dependency(\.defaultDatabase) var database

			@Test("Deleting a profile cascades to its core children")
			func cascadeFromProfile() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Job.Draft(id: UUID(-2), profileID: UUID(-1), company: "Acme")
						BankAccount.Draft(id: UUID(-3), profileID: UUID(-1), bankName: "Chase")
						Subscription.Draft(id: UUID(-4), profileID: UUID(-1), name: "Netflix")
						Vehicle.Draft(id: UUID(-5), profileID: UUID(-1), make: "Honda")
					}
				}

				try await database.write { db in
					try Profile.find(UUID(-1)).delete().execute(db)
				}

				let jobs = try await database.read { db in try Job.fetchCount(db) }
				let banks = try await database.read { db in try BankAccount.fetchCount(db) }
				let subs = try await database.read { db in try Subscription.fetchCount(db) }
				let vehicles = try await database.read { db in try Vehicle.fetchCount(db) }

				#expect(jobs == 0)
				#expect(banks == 0)
				#expect(subs == 0)
				#expect(vehicles == 0)
			}
		}

	}
}
