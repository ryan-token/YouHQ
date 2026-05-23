//
//  UtilityTests.swift
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
	@Suite("Utilities")
	struct UtilityTests {

		@Suite("View model")
		struct ViewModel {
			@Dependency(\.defaultDatabase) var database

			@Test("Load fetches utilities for a residence")
			func loadForResidence() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						Utility.Draft(
							id: UUID(-3), residenceID: UUID(-2),
							type: .electric, provider: "PG&E",
							approximateMonthlyCost: 120
						)
						Utility.Draft(
							id: UUID(-4), residenceID: UUID(-2),
							type: .internet, provider: "Comcast",
							approximateMonthlyCost: 80
						)
					}
				}

				let vm = UtilityViewModel()
				await vm.load(for: UUID(-2))

				#expect(vm.utilities.count == 2)
			}

			@Test("Utilities are scoped to residence")
			func scopedToResidence() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "Home 1")
						Residence.Draft(id: UUID(-3), profileID: UUID(-1), street: "Home 2")
						Utility.Draft(id: UUID(-4), residenceID: UUID(-2), type: .electric, provider: "PG&E")
						Utility.Draft(id: UUID(-5), residenceID: UUID(-3), type: .gas, provider: "SoCal Gas")
					}
				}

				let vm = UtilityViewModel()
				await vm.load(for: UUID(-2))

				#expect(vm.utilities.count == 1)
				let utility = try #require(vm.utilities.first)
				#expect(utility.provider == "PG&E")
			}

			@Test("Create draft has correct residence ID and defaults")
			func createDraft() {
				let vm = UtilityViewModel()
				let draft = vm.createDraft(for: UUID(-1))

				#expect(draft.residenceID == UUID(-1))
				#expect(draft.type == .electric)
				#expect(draft.provider == "")
				#expect(draft.approximateMonthlyCost == nil)
			}

			@Test("Delete removes utility from database")
			func deleteUtility() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						Utility.Draft(id: UUID(-3), residenceID: UUID(-2), type: .water, provider: "City Water")
					}
				}

				let vm = UtilityViewModel()
				await vm.load(for: UUID(-2))

				let utility = try #require(vm.utilities.first)
				vm.delete(utility)

				let remaining = try await database.read { db in try Utility.fetchCount(db) }
				#expect(remaining == 0)
			}

			@Test("Multiple utilities accumulate costs correctly")
			func multipleCosts() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						Utility.Draft(
							id: UUID(-3), residenceID: UUID(-2),
							type: .electric, provider: "PG&E",
							approximateMonthlyCost: 100
						)
						Utility.Draft(
							id: UUID(-4), residenceID: UUID(-2),
							type: .water, provider: "City",
							approximateMonthlyCost: 50
						)
						Utility.Draft(
							id: UUID(-5), residenceID: UUID(-2),
							type: .internet, provider: "Comcast",
							approximateMonthlyCost: nil
						)
					}
				}

				let vm = UtilityViewModel()
				await vm.load(for: UUID(-2))

				let totalCost = vm.utilities.compactMap(\.approximateMonthlyCost).reduce(0, +)
				#expect(totalCost == 150)
			}
		}

		// MARK: - Cascade Deletion

		@Suite("Cascade deletion")
		struct CascadeDeletion {
			@Dependency(\.defaultDatabase) var database

			@Test("Deleting a residence cascades to its utilities")
			func cascadeFromResidence() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						Utility.Draft(id: UUID(-3), residenceID: UUID(-2), type: .electric, provider: "PG&E")
						Utility.Draft(id: UUID(-4), residenceID: UUID(-2), type: .water, provider: "City")
					}
				}

				try await database.write { db in
					try Residence.find(UUID(-2)).delete().execute(db)
				}

				let count = try await database.read { db in try Utility.fetchCount(db) }
				#expect(count == 0)
			}

			@Test("Deleting a profile cascades through residence to utilities")
			func cascadeFromProfile() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						Utility.Draft(id: UUID(-3), residenceID: UUID(-2), type: .electric, provider: "PG&E")
					}
				}

				try await database.write { db in
					try Profile.find(UUID(-1)).delete().execute(db)
				}

				let utilityCount = try await database.read { db in try Utility.fetchCount(db) }
				let residenceCount = try await database.read { db in try Residence.fetchCount(db) }
				#expect(utilityCount == 0)
				#expect(residenceCount == 0)
			}
		}
	}
}
