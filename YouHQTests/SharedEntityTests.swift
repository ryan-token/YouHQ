//
//  SharedEntityTests.swift
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
	@Suite("Insurance policies")
	struct InsurancePolicyTests {

		@Suite("Residence insurance")
		struct ResidenceInsurance {
			@Dependency(\.defaultDatabase) var database

			@Test("Load fetches policies for a residence")
			func loadForResidence() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						InsurancePolicy.Draft(
							id: UUID(-3),
							profileID: UUID(-1),
							residenceID: UUID(-2),
							type: .renters,
							provider: "State Farm"
						)
						InsurancePolicy.Draft(
							id: UUID(-4),
							profileID: UUID(-1),
							residenceID: UUID(-2),
							type: .home,
							provider: "Allstate"
						)
					}
				}

				let vm = InsurancePolicyViewModel()
				await vm.load(for: UUID(-2))

				#expect(vm.insurancePolicies.count == 2)
			}

			@Test("Create draft for residence defaults to renters type")
			func createResidenceDraft() {
				let vm = InsurancePolicyViewModel()
				let draft = vm.createDraft(for: UUID(-1), profileID: UUID(-2))

				#expect(draft.residenceID == UUID(-1))
				#expect(draft.profileID == UUID(-2))
				#expect(draft.type == .renters)
				#expect(draft.vehicleID == nil)
			}
		}

		@Suite("Vehicle insurance")
		struct VehicleInsurance {
			@Dependency(\.defaultDatabase) var database

			@Test("Load fetches policies for a vehicle")
			func loadForVehicle() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Vehicle.Draft(id: UUID(-2), profileID: UUID(-1), make: "Toyota")
						InsurancePolicy.Draft(
							id: UUID(-3),
							profileID: UUID(-1),
							vehicleID: UUID(-2),
							type: .auto,
							provider: "Geico"
						)
					}
				}

				let vm = InsurancePolicyViewModel()
				await vm.loadVehicle(for: UUID(-2))

				#expect(vm.insurancePolicies.count == 1)
			}

			@Test("Create draft for vehicle defaults to auto type")
			func createVehicleDraft() {
				let vm = InsurancePolicyViewModel()
				let draft = vm.createVehicleDraft(for: UUID(-1), profileID: UUID(-2))

				#expect(draft.vehicleID == UUID(-1))
				#expect(draft.profileID == UUID(-2))
				#expect(draft.type == .auto)
				#expect(draft.residenceID == nil)
			}
		}

		@Suite("Delete")
		struct Delete {
			@Dependency(\.defaultDatabase) var database

			@Test("Delete removes policy from database")
			func deletePolicy() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						InsurancePolicy.Draft(id: UUID(-2), profileID: UUID(-1), type: .health, provider: "Aetna")
					}
				}

				let vm = InsurancePolicyViewModel()
				let policy = try await database.read { db in
					try InsurancePolicy.find(UUID(-2)).fetchOne(db)!
				}
				vm.delete(policy)

				let count = try await database.read { db in try InsurancePolicy.fetchCount(db) }
				#expect(count == 0)
			}
		}
	}

	@Suite("Other items")
	struct OtherItemTests {
		@Dependency(\.defaultDatabase) var database

		@Test("Load residence others fetches items for a residence")
		func loadResidenceOthers() async throws {
			try await database.write { db in
				try db.seed {
					Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
					Other.Draft(
						id: UUID(-3),
						profileID: UUID(-1),
						residenceID: UUID(-2),
						category: .homes,
						name: "HOA Fees"
					)
				}
			}

			let vm = OtherItemViewModel()
			await vm.loadResidence(for: UUID(-2))

			#expect(vm.others.count == 1)
		}

		@Test("Load vehicle others fetches items for a vehicle")
		func loadVehicleOthers() async throws {
			try await database.write { db in
				try db.seed {
					Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					Vehicle.Draft(id: UUID(-2), profileID: UUID(-1), make: "Toyota")
					Other.Draft(
						id: UUID(-3),
						profileID: UUID(-1),
						vehicleID: UUID(-2),
						category: .vehicles,
						name: "Parking Permit"
					)
				}
			}

			let vm = OtherItemViewModel()
			await vm.loadVehicle(for: UUID(-2))

			#expect(vm.others.count == 1)
		}

		@Test("Load by category fetches items for category and profile")
		func loadByCategory() async throws {
			try await database.write { db in
				try db.seed {
					Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					Other.Draft(id: UUID(-2), profileID: UUID(-1), category: .media, name: "Media item")
					Other.Draft(id: UUID(-3), profileID: UUID(-1), category: .career, name: "Career item")
					Other.Draft(id: UUID(-4), profileID: UUID(-1), category: .media, name: "Another media")
				}
			}

			let vm = OtherItemViewModel()
			await vm.loadCategory(for: .media, profileID: UUID(-1))

			#expect(vm.others.count == 2)
		}

		@Test("Create residence draft has correct category and IDs")
		func createResidenceDraft() {
			let vm = OtherItemViewModel()
			let draft = vm.createResidenceDraft(for: UUID(-1), profileID: UUID(-2))

			#expect(draft.residenceID == UUID(-1))
			#expect(draft.profileID == UUID(-2))
			#expect(draft.category == .homes)
			#expect(draft.vehicleID == nil)
		}

		@Test("Create vehicle draft has correct category and IDs")
		func createVehicleDraft() {
			let vm = OtherItemViewModel()
			let draft = vm.createVehicleDraft(for: UUID(-1), profileID: UUID(-2))

			#expect(draft.vehicleID == UUID(-1))
			#expect(draft.profileID == UUID(-2))
			#expect(draft.category == .vehicles)
			#expect(draft.residenceID == nil)
		}

		@Test("Create category draft has correct category")
		func createCategoryDraft() {
			let vm = OtherItemViewModel()
			let draft = vm.createCategoryDraft(for: .money, profileID: UUID(-1))

			#expect(draft.category == .money)
			#expect(draft.profileID == UUID(-1))
			#expect(draft.residenceID == nil)
			#expect(draft.vehicleID == nil)
		}

		@Test("Delete removes other item from database")
		func deleteOther() async throws {
			try await database.write { db in
				try db.seed {
					Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
					Other.Draft(
						id: UUID(-3),
						profileID: UUID(-1),
						residenceID: UUID(-2),
						category: .homes,
						name: "HOA"
					)
				}
			}

			let vm = OtherItemViewModel()
			await vm.loadResidence(for: UUID(-2))
			let first = try #require(vm.others.first)
			vm.delete(first)

			let count = try await database.read { db in try Other.fetchCount(db) }
			#expect(count == 0)
		}

		@Test("Cascade deletion from residence removes others")
		func cascadeFromResidence() async throws {
			try await database.write { db in
				try db.seed {
					Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
					Other.Draft(
						id: UUID(-3),
						profileID: UUID(-1),
						residenceID: UUID(-2),
						category: .homes,
						name: "HOA Fees"
					)
				}
			}

			try await database.write { db in
				try Residence.find(UUID(-2)).delete().execute(db)
			}

			let count = try await database.read { db in try Other.fetchCount(db) }
			#expect(count == 0)
		}
	}
}
