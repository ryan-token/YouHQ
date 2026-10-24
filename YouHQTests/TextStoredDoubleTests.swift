//
//  TextStoredDoubleTests.swift
//  YouHQTests
//
//  Created by Ryan Token on 10/22/26.
//

import Dependencies
import DependenciesTestSupport
import Foundation
import SQLiteData
import Testing

@testable import YouHQ

extension YouHQTests {
	@Suite("Text-stored amounts")
	struct TextStoredDoubleTests {
		@Dependency(\.defaultDatabase) var database

		@Test("An amount in a TEXT column round-trips and stays stored as text")
		func roundTrip() async throws {
			try await database.write { db in
				try db.seed {
					Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					Residence.Draft(id: UUID(-2), profileID: UUID(-1), monthlyCost: 1234.56)
				}
			}

			try await database.read { db in
				let residence = try #require(try Residence.find(UUID(-2)).fetchOne(db))
				#expect(residence.monthlyCost == 1234.56)
				let storage = try String.fetchOne(db, sql: "SELECT typeof(\"monthlyCost\") FROM \"residences\"")
				#expect(storage == "text")
			}
		}

		@Test("Updating and clearing an amount reads back what was written")
		func updateAndClear() async throws {
			try await database.write { db in
				try db.seed {
					Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					Residence.Draft(id: UUID(-2), profileID: UUID(-1), monthlyCost: 100)
				}
				try Residence.find(UUID(-2)).update { $0.monthlyCost = #bind(0.1) }.execute(db)
			}
			let updated = try await database.read { db in
				try Residence.find(UUID(-2)).fetchOne(db)?.monthlyCost
			}
			#expect(updated == 0.1)

			try await database.write { db in
				try Residence.find(UUID(-2)).update { $0.monthlyCost = #bind(nil) }.execute(db)
			}
			let cleared = try await database.read { db in
				try Residence.find(UUID(-2)).fetchOne(db)
			}
			#expect(try #require(cleared).monthlyCost == nil)
		}
	}
}
