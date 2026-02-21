//
//  ResidenceTests.swift
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
	@Suite("Residences")
	struct ResidenceTests {

		@Suite("Add residence")
		struct AddResidence {
			@Dependency(\.defaultDatabase) var database

			@Test("Save creates residence in database")
			func saveCreatesResidence() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(
							id: UUID(-1),
							name: "Test",
							createdAt: Date(),
							updatedAt: Date()
						)
					}
				}
				let profile = try await database.read { db in
					try Profile.find(UUID(-1)).fetchOne(db)!
				}

				let vm = AddResidenceSheet.ViewModel(profileID: profile.id)
				vm.street = "456 Oak Ave"
				vm.city = "Denver"
				vm.state = "CO"
				vm.zipCode = "80202"
				vm.type = .house
				vm.costType = .mortgage
				vm.monthlyCost = 3200
				vm.notes = "New build"

				let saved = vm.save()
				let savedResidence = try #require(saved)

				#expect(savedResidence.street == "456 Oak Ave")
				#expect(savedResidence.city == "Denver")
				#expect(savedResidence.state == "CO")
				#expect(savedResidence.type == .house)
				#expect(savedResidence.monthlyCost == 3200)
				#expect(savedResidence.notes == "New build")

				// Verify it persisted in the database
				let fetched = try await database.read { db in
					try Residence.find(savedResidence.id).fetchOne(db)
				}
				let fetchedResidence = try #require(fetched)
				#expect(fetchedResidence.street == "456 Oak Ave")
			}

			@Test("Save returns nil when street is empty")
			func saveRequiresStreet() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(
							id: UUID(-1),
							name: "Test",
							createdAt: Date(),
							updatedAt: Date()
						)
					}
				}

				let vm = AddResidenceSheet.ViewModel(profileID: UUID(-1))
				// street is empty by default
				#expect(!vm.isValid)
			}

			@Test("Validation requires non-empty street")
			func validationRequiresStreet() {
				let vm = AddResidenceSheet.ViewModel(profileID: UUID(-1))

				#expect(!vm.isValid)

				vm.street = "  "
				#expect(!vm.isValid)

				vm.street = "123 Elm St"
				#expect(vm.isValid)
			}

			@Test("Move out date is nil when toggle is off")
			func moveOutDateToggle() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(
							id: UUID(-1),
							name: "Test",
							createdAt: Date(),
							updatedAt: Date()
						)
					}
				}

				let vm = AddResidenceSheet.ViewModel(profileID: UUID(-1))
				vm.street = "789 Pine Rd"
				vm.moveOutDate = Date()
				vm.hasMoveOutDate = false

				let saved = try #require(vm.save())
				#expect(saved.moveOutDate == nil)
			}

			@Test("Move out date is preserved when toggle is on")
			func moveOutDatePreserved() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					}
				}

				let moveOut = Date(timeIntervalSince1970: 2_000_000)
				let vm = AddResidenceSheet.ViewModel(profileID: UUID(-1))
				vm.street = "789 Pine Rd"
				vm.moveOutDate = moveOut
				vm.hasMoveOutDate = true

				let saved = try #require(vm.save())
				#expect(saved.moveOutDate != nil)
			}

			@Test("isValid is independent of other fields")
			func onlyStreetMatters() {
				let vm = AddResidenceSheet.ViewModel(profileID: UUID(-1))
				vm.street = "123 Main"
				#expect(vm.isValid)
				#expect(vm.city == "")
				#expect(vm.state == "")
				#expect(vm.zipCode == "")
			}

			@Test("Initial values are correct")
			func initialDefaults() {
				let vm = AddResidenceSheet.ViewModel(profileID: UUID(-1))

				#expect(vm.selectedProfileID == UUID(-1))
				#expect(vm.type == .apartment)
				#expect(vm.isCurrent == true)
				#expect(vm.street == "")
				#expect(vm.unit == "")
				#expect(vm.city == "")
				#expect(vm.state == "")
				#expect(vm.zipCode == "")
				#expect(vm.country == "")
				#expect(vm.moveInDate == nil)
				#expect(vm.moveOutDate == nil)
				#expect(vm.hasMoveOutDate == false)
				#expect(vm.monthlyCost == nil)
				#expect(vm.costType == .rent)
				#expect(vm.url == "")
				#expect(vm.notes == "")
			}
		}

		// MARK: - UtilityViewModel Tests

		@Suite("Utilities")
		struct Utilities {
			@Dependency(\.defaultDatabase) var database

			@Test("Load fetches utilities for a residence")
			func loadUtilities() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							street: "100 Test St"
						)
						Utility.Draft(
							id: UUID(-3),
							residenceID: UUID(-2),
							type: .electric,
							provider: "City Power"
						)
						Utility.Draft(
							id: UUID(-4),
							residenceID: UUID(-2),
							type: .water,
							provider: "City Water"
						)
					}
				}

				let vm = UtilityViewModel()
				await vm.load(for: UUID(-2))

				#expect(vm.utilities.count == 2)
			}

			@Test("Create draft sets correct residence ID")
			func createDraft() {
				let vm = UtilityViewModel()
				let residenceID = UUID(-1)
				let draft = vm.createDraft(for: residenceID)

				#expect(draft.residenceID == residenceID)
				#expect(draft.type == .electric)
				#expect(draft.provider == "")
			}

			@Test("Delete removes utility from database")
			func deleteUtility() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "100 Test St")
						Utility.Draft(id: UUID(-3), residenceID: UUID(-2), type: .electric, provider: "PG&E")
					}
				}

				let vm = UtilityViewModel()
				await vm.load(for: UUID(-2))
				#expect(vm.utilities.count == 1)

				let first = try #require(vm.utilities.first)
				vm.delete(first)

				let remaining = try await database.read { db in
					try Utility.where { $0.residenceID.eq(UUID(-2)) }.fetchCount(db)
				}
				#expect(remaining == 0)
			}
		}

		// MARK: - Residence Cascade Deletion

		@Suite("Cascade deletion")
		struct CascadeDeletion {
			@Dependency(\.defaultDatabase) var database

			@Test("Deleting a residence cascades to utilities")
			func cascadeToUtilities() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "100 Test St")
						Utility.Draft(id: UUID(-3), residenceID: UUID(-2), type: .electric, provider: "PG&E")
						Utility.Draft(id: UUID(-4), residenceID: UUID(-2), type: .water, provider: "City Water")
					}
				}

				try await database.write { db in
					try Residence.find(UUID(-2)).delete().execute(db)
				}

				let utilityCount = try await database.read { db in
					try Utility.where { $0.residenceID.eq(UUID(-2)) }.fetchCount(db)
				}
				#expect(utilityCount == 0)
			}

			@Test("Deleting a residence cascades to maintenance items")
			func cascadeToMaintenanceItems() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "100 Test St")
						MaintenanceItem.Draft(
							id: UUID(-3),
							residenceID: UUID(-2),
							vehicleID: nil,
							name: "Change HVAC filter"
						)
					}
				}

				try await database.write { db in
					try Residence.find(UUID(-2)).delete().execute(db)
				}

				let count = try await database.read { db in
					try MaintenanceItem.fetchCount(db)
				}
				#expect(count == 0)
			}

			@Test("Deleting a residence cascades to paint colors")
			func cascadeToPaintColors() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "100 Test St")
						PaintColor.Draft(
							id: UUID(-3),
							residenceID: UUID(-2),
							vehicleID: nil,
							manufacturer: "Benjamin Moore",
							colorName: "Simply White"
						)
					}
				}

				try await database.write { db in
					try Residence.find(UUID(-2)).delete().execute(db)
				}

				let count = try await database.read { db in
					try PaintColor.fetchCount(db)
				}
				#expect(count == 0)
			}

			@Test("Deleting a profile cascades to residences and children")
			func cascadeFromProfile() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "100 Test St")
						Utility.Draft(id: UUID(-3), residenceID: UUID(-2), type: .electric, provider: "PG&E")
					}
				}

				try await database.write { db in
					try Profile.find(UUID(-1)).delete().execute(db)
				}

				let residenceCount = try await database.read { db in try Residence.fetchCount(db) }
				let utilityCount = try await database.read { db in try Utility.fetchCount(db) }
				#expect(residenceCount == 0)
				#expect(utilityCount == 0)
			}
		}

		// MARK: - Residence Schema Computed Properties

		@Suite("Address formatting")
		struct AddressFormatting {
			@Dependency(\.defaultDatabase) var database

			@Test("Full address includes street, city, state, zip")
			func fullAddress() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							street: "123 Main St",
							unit: "Apt 4B",
							city: "Austin",
							state: "TX",
							zipCode: "78701",
							country: "USA"
						)
					}
				}

				let residence = try await database.read { db in
					try Residence.find(UUID(-2)).fetchOne(db)!
				}

				#expect(residence.address == "123 Main St, Apt 4B, Austin TX 78701")
			}

			@Test("Address excludes USA country")
			func addressExcludesUSA() {
				let residence = Residence(
					id: UUID(-1),
					profileID: UUID(-2),
					street: "123 Main St",
					city: "Austin",
					state: "TX",
					zipCode: "78701",
					country: "USA"
				)
				#expect(!residence.address.contains("USA"))
			}

			@Test("Address includes non-USA country")
			func addressIncludesNonUSACountry() {
				let residence = Residence(
					id: UUID(-1),
					profileID: UUID(-2),
					street: "10 Downing St",
					city: "London",
					country: "UK"
				)
				#expect(residence.address.contains("UK"))
			}

			@Test("Short address omits zip and country")
			func shortAddress() {
				let residence = Residence(
					id: UUID(-1),
					profileID: UUID(-2),
					street: "123 Main St",
					unit: "Apt 4B",
					city: "Austin",
					state: "TX",
					zipCode: "78701",
					country: "USA"
				)
				#expect(residence.shortAddress == "123 Main St, Apt 4B, Austin, TX")
			}

			@Test("unitOrStreet prefers unit when present")
			func unitOrStreetPrefersUnit() {
				let residence = Residence(
					id: UUID(-1),
					profileID: UUID(-2),
					street: "123 Main St",
					unit: "Suite 200"
				)
				#expect(residence.unitOrStreet == "Suite 200")
			}

			@Test("unitOrStreet falls back to street")
			func unitOrStreetFallsBackToStreet() {
				let residence = Residence(
					id: UUID(-1),
					profileID: UUID(-2),
					street: "123 Main St",
					unit: ""
				)
				#expect(residence.unitOrStreet == "123 Main St")
			}

			@Test("unitOrStreet returns nil when both empty")
			func unitOrStreetReturnsNil() {
				let residence = Residence(
					id: UUID(-1),
					profileID: UUID(-2),
					street: "",
					unit: ""
				)
				#expect(residence.unitOrStreet == nil)
			}
		}

		// MARK: - Residence Query Tests

		@Suite("Queries")
		struct Queries {
			@Dependency(\.defaultDatabase) var database

			@Test("Residences are fetched by profile")
			func fetchByProfile() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Alice", createdAt: Date(), updatedAt: Date())
						Profile.Draft(id: UUID(-2), name: "Bob", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-3), profileID: UUID(-1), street: "Alice House")
						Residence.Draft(id: UUID(-4), profileID: UUID(-2), street: "Bob House")
					}
				}

				let aliceResidences = try await database.read { db in
					try Residence.where { $0.profileID.eq(UUID(-1)) }.fetchAll(db)
				}
				#expect(aliceResidences.count == 1)
				let aliceResidence = try #require(aliceResidences.first)
				#expect(aliceResidence.street == "Alice House")
			}

			@Test("Residences ordered by street")
			func orderedByStreet() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "Zebra Ln")
						Residence.Draft(id: UUID(-3), profileID: UUID(-1), street: "Apple Dr")
						Residence.Draft(id: UUID(-4), profileID: UUID(-1), street: "Maple Ave")
					}
				}

				let residences = try await database.read { db in
					try Residence
						.where { $0.profileID.eq(UUID(-1)) }
						.order { $0.street }
						.fetchAll(db)
				}
				#expect(residences.map(\.street) == ["Apple Dr", "Maple Ave", "Zebra Ln"])
			}
		}
	}
}
