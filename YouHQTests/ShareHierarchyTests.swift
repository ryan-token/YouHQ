//
//  ShareHierarchyTests.swift
//  YouHQTests
//
//  Created by Ryan Token on 7/28/26.
//

import Dependencies
import DependenciesTestSupport
import Foundation
import SQLiteData
import Testing

@testable import YouHQ

extension YouHQTests {
	/// Guards the schema shape that decides whether a record reaches the people a profile is
	/// shared with, and the deletes that used to be foreign key cascades.
	@Suite("Share hierarchy")
	struct ShareHierarchyTests {
		@Dependency(\.defaultDatabase) var database

		/// The bug this schema exists to prevent.
		///
		/// SQLiteData gives a record a CloudKit parent only when its table has exactly one
		/// foreign key, and a record with no parent is a root record that no share includes.
		/// A second foreign key on any of these silently makes its records invisible to share
		/// recipients while still syncing perfectly to the owner's own devices, so nothing
		/// short of two iCloud accounts would catch it by hand.
		@Test("Shared child tables have exactly one foreign key", arguments: singleProfileForeignKeyTables)
		func exactlyOneForeignKey(table: String) async throws {
			let referencedTables = try await database.read { db in
				try String.fetchAll(db, sql: "SELECT \"table\" FROM pragma_foreign_key_list(?)", arguments: [table])
			}
			#expect(referencedTables == ["profiles"], "\(table) must keep 'profileID' as its only foreign key")
		}

		/// Removing those foreign keys removed their `ON DELETE CASCADE`, which triggers now
		/// reproduce. Without them a deleted home leaves maintenance items behind that keep
		/// scheduling notifications, and photos that keep consuming iCloud storage.
		@Test("Deleting a residence deletes everything attached to it")
		func cascadeFromResidence() async throws {
			try await seedResidenceWithChildren()

			try await database.write { db in
				try Residence.find(UUID(-2)).delete().execute(db)
			}

			try await expectNoChildrenRemain()
		}

		@Test("Deleting a vehicle deletes everything attached to it")
		func cascadeFromVehicle() async throws {
			try await seedVehicleWithChildren()

			try await database.write { db in
				try Vehicle.find(UUID(-3)).delete().execute(db)
			}

			try await expectNoChildrenRemain()
		}

		/// Photos hang off six different parents, and each of those lost its cascade too.
		@Test("Deleting a maintenance item deletes its photos and completions")
		func cascadeFromMaintenanceItem() async throws {
			try await seedResidenceWithChildren()

			try await database.write { db in
				try MaintenanceItem.find(UUID(-4)).delete().execute(db)
			}

			let assets = try await database.read { db in try Asset.fetchCount(db) }
			let completions = try await database.read { db in try MaintenanceCompletion.fetchCount(db) }
			#expect(assets == 0)
			#expect(completions == 0)
		}

		/// The column that carries the CloudKit parent has to be populated for records created
		/// by screens that only know a residence or a vehicle, or they stay unshared.
		@Test("A maintenance item created without a profile is given its residence's profile")
		func backfillsProfileOnInsert() async throws {
			try await database.write { db in
				try db.seed {
					Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
					MaintenanceItem.Draft(id: UUID(-4), profileID: nil, residenceID: UUID(-2), vehicleID: nil)
				}
			}

			let item = try await database.read { db in
				try #require(try MaintenanceItem.find(UUID(-4)).fetchOne(db))
			}
			#expect(item.profileID == UUID(-1))
		}

		/// Runs the table rebuild against a database that already holds records, which is the
		/// only state real users will be in and the one the rest of the suite cannot reach:
		/// every other test migrates a database that was empty when the rebuild ran.
		@Suite("Migrating a populated database", .serialized)
		struct Migration {
			@Test("Rebuilding preserves every row, column and relationship")
			func rebuildPreservesData() async throws {
				let database = try migratedToPreviousVersion()

				try await database.write { db in
					try db.execute(
						sql: """
							INSERT INTO "profiles" ("id", "name", "createdAt", "updatedAt")
							VALUES ('P1', 'Me', '2026-01-01', '2026-01-01');
							INSERT INTO "residences" ("id", "profileID") VALUES ('R1', 'P1');
							INSERT INTO "vehicles" ("id", "profileID") VALUES ('V1', 'P1');
							INSERT INTO "insurancePolicies"
								("id", "profileID", "residenceID", "type", "provider", "notes", "currencyCode")
								VALUES ('I1', 'P1', 'R1', 'Home', 'State Farm', 'keep me', 'USD');
							INSERT INTO "maintenanceItems" ("id", "residenceID", "name")
								VALUES ('M1', 'R1', 'Furnace filter');
							INSERT INTO "maintenanceItems" ("id", "vehicleID", "name")
								VALUES ('M2', 'V1', 'Tire rotation');
							INSERT INTO "paintColors" ("id", "residenceID", "colorName")
								VALUES ('C1', 'R1', 'Alabaster');
							INSERT INTO "assets" ("id", "profileID", "maintenanceItemID", "imageData")
								VALUES ('A1', 'P1', 'M1', x'DEADBEEF');
							INSERT INTO "maintenanceCompletions" ("id", "maintenanceItemID")
								VALUES ('X1', 'M1');
							"""
					)
				}

				try youHQMigrator().migrate(database)

				try await database.read { db in
					// Photos and history are what a cascading DROP TABLE would have taken.
					#expect(try Int.fetchOne(db, sql: "SELECT count(*) FROM \"assets\"") == 1)
					#expect(try Int.fetchOne(db, sql: "SELECT count(*) FROM \"maintenanceCompletions\"") == 1)

					// `currencyCode` was appended by a later migration, so a positional copy
					// would shift these two columns into each other without tripping STRICT.
					let notes = try String.fetchOne(db, sql: "SELECT \"notes\" FROM \"insurancePolicies\"")
					let currency = try String.fetchOne(db, sql: "SELECT \"currencyCode\" FROM \"insurancePolicies\"")
					#expect(notes == "keep me")
					#expect(currency == "USD")

					// Resolved through each row's own parent, never a device-wide profile.
					let viaResidence = try String.fetchOne(
						db, sql: "SELECT \"profileID\" FROM \"maintenanceItems\" WHERE \"id\" = 'M1'"
					)
					let viaVehicle = try String.fetchOne(
						db, sql: "SELECT \"profileID\" FROM \"maintenanceItems\" WHERE \"id\" = 'M2'"
					)
					let paintColor = try String.fetchOne(
						db, sql: "SELECT \"profileID\" FROM \"paintColors\" WHERE \"id\" = 'C1'"
					)
					#expect(viaResidence == "P1")
					#expect(viaVehicle == "P1")
					#expect(paintColor == "P1")

					#expect(try Int.fetchOne(db, sql: "SELECT count(*) FROM pragma_foreign_key_check") == 0)
				}
			}

			/// Foreign keys in other tables must still name the real table. Renaming the
			/// original aside instead of the replacement would leave these pointing at a
			/// dropped table, which stops `SyncEngine` starting and cannot be recovered from.
			@Test("Rebuilding leaves other tables' foreign keys intact")
			func rebuildKeepsReferencesValid() async throws {
				let database = try migratedToPreviousVersion()
				try youHQMigrator().migrate(database)

				try await database.read { db in
					let assetTargets = try String.fetchAll(
						db, sql: "SELECT \"table\" FROM pragma_foreign_key_list('assets')"
					)
					let completionTargets = try String.fetchAll(
						db, sql: "SELECT \"table\" FROM pragma_foreign_key_list('maintenanceCompletions')"
					)
					#expect(assetTargets == ["profiles"])
					#expect(completionTargets == ["maintenanceItems"])
				}
			}

			/// A database as it stood immediately before the rebuild shipped.
			private func migratedToPreviousVersion() throws -> any DatabaseWriter {
				var configuration = Configuration()
				configuration.foreignKeysEnabled = true
				// The profile triggers guard on this function, so it has to resolve on the
				// connection exactly as `appDatabase()` arranges in production.
				configuration.prepareDatabase { db in
					db.add(function: SyncEngine.$isSynchronizing)
				}
				let database = try DatabaseQueue(configuration: configuration)
				try youHQMigrator().migrate(database, upTo: "Add plaintext salary column")
				return database
			}
		}

		// MARK: - Helpers

		/// A residence with one of every child that lost its foreign key, plus a photo and a
		/// completion hanging off the maintenance item.
		private func seedResidenceWithChildren() async throws {
			try await database.write { db in
				try db.seed {
					Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
					MaintenanceItem.Draft(id: UUID(-4), profileID: UUID(-1), residenceID: UUID(-2), vehicleID: nil)
					PaintColor.Draft(id: UUID(-5), profileID: UUID(-1), residenceID: UUID(-2), vehicleID: nil)
					InsurancePolicy.Draft(
						id: UUID(-6), profileID: UUID(-1), residenceID: UUID(-2), vehicleID: nil, type: .home
					)
					Other.Draft(
						id: UUID(-7), profileID: UUID(-1), residenceID: UUID(-2), vehicleID: nil,
						category: .homes, name: "Spare key"
					)
					MaintenanceCompletion.Draft(id: UUID(-8), maintenanceItemID: UUID(-4))
					Asset.Draft(
						id: UUID(-9), profileID: UUID(-1), residenceID: nil, vehicleID: nil,
						insurancePolicyID: nil, maintenanceItemID: UUID(-4), deviceID: nil, otherID: nil,
						imageData: Data([0x1])
					)
				}
			}
		}

		private func seedVehicleWithChildren() async throws {
			try await database.write { db in
				try db.seed {
					Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					Vehicle.Draft(id: UUID(-3), profileID: UUID(-1), make: "Honda")
					MaintenanceItem.Draft(id: UUID(-4), profileID: UUID(-1), residenceID: nil, vehicleID: UUID(-3))
					PaintColor.Draft(id: UUID(-5), profileID: UUID(-1), residenceID: nil, vehicleID: UUID(-3))
					InsurancePolicy.Draft(
						id: UUID(-6), profileID: UUID(-1), residenceID: nil, vehicleID: UUID(-3), type: .auto
					)
					Other.Draft(
						id: UUID(-7), profileID: UUID(-1), residenceID: nil, vehicleID: UUID(-3),
						category: .vehicles, name: "Garage opener"
					)
					MaintenanceCompletion.Draft(id: UUID(-8), maintenanceItemID: UUID(-4))
					Asset.Draft(
						id: UUID(-9), profileID: UUID(-1), residenceID: nil, vehicleID: nil,
						insurancePolicyID: nil, maintenanceItemID: UUID(-4), deviceID: nil, otherID: nil,
						imageData: Data([0x1])
					)
				}
			}
		}

		private func expectNoChildrenRemain() async throws {
			let counts = try await database.read { db in
				(
					maintenanceItems: try MaintenanceItem.fetchCount(db),
					paintColors: try PaintColor.fetchCount(db),
					policies: try InsurancePolicy.fetchCount(db),
					others: try Other.fetchCount(db),
					assets: try Asset.fetchCount(db),
					completions: try MaintenanceCompletion.fetchCount(db)
				)
			}
			#expect(counts.maintenanceItems == 0)
			#expect(counts.paintColors == 0)
			#expect(counts.policies == 0)
			#expect(counts.others == 0)
			#expect(counts.assets == 0)
			#expect(counts.completions == 0)
		}
	}
}
