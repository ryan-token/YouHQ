//
//  VehicleTests.swift
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
	@Suite("Vehicles")
	struct VehicleTests {

		@Suite("Add vehicle")
		struct AddVehicle {
			@Dependency(\.defaultDatabase) var database

			@Test("Save creates vehicle in database")
			func saveCreatesVehicle() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					}
				}

				let vm = AddVehicleSheet.ViewModel(profileID: UUID(-1))
				vm.make = "Toyota"
				vm.model = "Camry"
				vm.year = "2024"
				vm.color = "Silver"
				vm.type = .car
				vm.subType = .gas
				vm.costType = .loanPayment
				vm.monthlyCost = 450
				vm.notes = "Family sedan"

				let saved = vm.save()
				let savedVehicle = try #require(saved)

				#expect(savedVehicle.make == "Toyota")
				#expect(savedVehicle.model == "Camry")
				#expect(savedVehicle.year == "2024")
				#expect(savedVehicle.color == "Silver")
				#expect(savedVehicle.type == .car)
				#expect(savedVehicle.subType == .gas)
				#expect(savedVehicle.monthlyCost == 450)

				// Verify persistence
				let fetched = try await database.read { db in
					try Vehicle.find(savedVehicle.id).fetchOne(db)
				}
				#expect(fetched != nil)
				#expect(fetched?.make == "Toyota")
			}

			@Test("Validation requires non-empty make")
			func validationRequiresMake() {
				let vm = AddVehicleSheet.ViewModel(profileID: UUID(-1))

				#expect(!vm.isValid)

				vm.make = "   "
				#expect(!vm.isValid)

				vm.make = "Honda"
				#expect(vm.isValid)
			}

			@Test("Empty year and color save as nil")
			func emptyOptionalFieldsSaveAsNil() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					}
				}

				let vm = AddVehicleSheet.ViewModel(profileID: UUID(-1))
				vm.make = "Ford"
				vm.year = ""
				vm.color = ""

				let saved = try #require(vm.save())
				#expect(saved.year == nil)
				#expect(saved.color == nil)
			}
		}

		// MARK: - Vehicle.displayName Tests

		@Suite("Display name")
		struct DisplayName {
			@Test("Full display name includes year, make, model")
			func fullDisplayName() {
				let vehicle = Vehicle(
					id: UUID(-1),
					profileID: UUID(-2),
					make: "Toyota",
					model: "Camry",
					year: "2024"
				)
				#expect(vehicle.displayName == "2024 Toyota Camry")
			}

			@Test("Display name with only make and model")
			func makeAndModel() {
				let vehicle = Vehicle(
					id: UUID(-1),
					profileID: UUID(-2),
					make: "Honda",
					model: "Civic"
				)
				#expect(vehicle.displayName == "Honda Civic")
			}

			@Test("Display name falls back to Vehicle when all empty")
			func fallsBackToVehicle() {
				let vehicle = Vehicle(
					id: UUID(-1),
					profileID: UUID(-2),
					make: "",
					model: ""
				)
				#expect(vehicle.displayName == "Vehicle")
			}

			@Test("Display name skips empty year")
			func skipsEmptyYear() {
				let vehicle = Vehicle(
					id: UUID(-1),
					profileID: UUID(-2),
					make: "Tesla",
					model: "Model 3",
					year: ""
				)
				#expect(vehicle.displayName == "Tesla Model 3")
			}
		}

		// MARK: - Vehicle Cascade Deletion

		@Suite("Cascade deletion")
		struct CascadeDeletion {
			@Dependency(\.defaultDatabase) var database

			@Test("Deleting a vehicle cascades to insurance policies")
			func cascadeToInsurance() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Vehicle.Draft(id: UUID(-2), profileID: UUID(-1), make: "Toyota")
						InsurancePolicy.Draft(
							id: UUID(-3),
							profileID: UUID(-1),
							residenceID: nil,
							vehicleID: UUID(-2),
							type: .auto,
							provider: "State Farm"
						)
					}
				}

				try await database.write { db in
					try Vehicle.find(UUID(-2)).delete().execute(db)
				}

				let count = try await database.read { db in
					try InsurancePolicy.fetchCount(db)
				}
				#expect(count == 0)
			}

			@Test("Deleting a vehicle cascades to maintenance items")
			func cascadeToMaintenance() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Vehicle.Draft(id: UUID(-2), profileID: UUID(-1), make: "Honda")
						MaintenanceItem.Draft(
							id: UUID(-3),
							residenceID: nil,
							vehicleID: UUID(-2),
							name: "Oil change"
						)
					}
				}

				try await database.write { db in
					try Vehicle.find(UUID(-2)).delete().execute(db)
				}

				let count = try await database.read { db in
					try MaintenanceItem.fetchCount(db)
				}
				#expect(count == 0)
			}

			@Test("Deleting a vehicle cascades to paint colors")
			func cascadeToPaintColors() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Vehicle.Draft(id: UUID(-2), profileID: UUID(-1), make: "BMW")
						PaintColor.Draft(
							id: UUID(-3),
							residenceID: nil,
							vehicleID: UUID(-2),
							manufacturer: "PPG",
							colorName: "Alpine White"
						)
					}
				}

				try await database.write { db in
					try Vehicle.find(UUID(-2)).delete().execute(db)
				}

				let count = try await database.read { db in
					try PaintColor.fetchCount(db)
				}
				#expect(count == 0)
			}

		}

	}
}
