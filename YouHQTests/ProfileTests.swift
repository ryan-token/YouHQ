//
//  ProfileTests.swift
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
	@Suite("Profiles")
	struct ProfileTests {

		@Suite("CRUD")
		struct CRUD {
			@Dependency(\.defaultDatabase) var database

			@Test("Create profile inserts into database")
			func createProfile() async throws {
				try await database.write { db in
					try Profile.insert {
						Profile.Draft(
							id: UUID(-1),
							name: "Test Profile",
							createdAt: Date(),
							updatedAt: Date()
						)
					}
					.execute(db)
				}

				let profile = try await database.read { db in
					try Profile.find(UUID(-1)).fetchOne(db)
				}
				let fetched = try #require(profile)
				#expect(fetched.name == "Test Profile")
			}

			@Test("Multiple profiles can coexist")
			func multipleProfiles() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Alice", createdAt: Date(), updatedAt: Date())
						Profile.Draft(id: UUID(-2), name: "Bob", createdAt: Date(), updatedAt: Date())
						Profile.Draft(id: UUID(-3), name: "Charlie", createdAt: Date(), updatedAt: Date())
					}
				}

				let count = try await database.read { db in try Profile.fetchCount(db) }
				#expect(count == 3)
			}

			@Test("Delete profile removes it from database")
			func deleteProfile() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "ToDelete", createdAt: Date(), updatedAt: Date())
					}
				}

				try await database.write { db in
					try Profile.find(UUID(-1)).delete().execute(db)
				}

				let deleted = try await database.read { db in
					try Profile.find(UUID(-1)).fetchOne(db)
				}
				#expect(deleted == nil)
			}
		}

		// MARK: - OnboardingProfileCreationView.ViewModel profile creation tests

		@Suite("Profile setup")
		struct ProfileSetup {
			@Dependency(\.defaultDatabase) var database

			@Test("isProfileNameEmpty rejects whitespace-only names")
			func profileNameValidation() {
				let vm = OnboardingProfileCreationView.ViewModel()

				vm.newProfileName = ""
				#expect(vm.isProfileNameEmpty)

				vm.newProfileName = "   "
				#expect(vm.isProfileNameEmpty)

				vm.newProfileName = "Ryan"
				#expect(!vm.isProfileNameEmpty)
			}

			@Test("createProfile inserts into database, sets selected ID, and marks creation flags")
			func createProfile() async throws {
				let vm = OnboardingProfileCreationView.ViewModel()
				vm.createProfile(named: "New Profile")

				let count = try await database.read { db in try Profile.fetchCount(db) }
				#expect(count == 1)

				// Verify the profile was auto-selected and the view-model flags reflect it
				#expect(!vm.selectedProfileIDString.isEmpty)
				#expect(vm.createdNewProfile)
				#expect(vm.createdProfileName == "New Profile")
			}
		}

		// MARK: - Profile Cascade Tests

		@Suite("Full cascade")
		struct FullCascade {
			@Dependency(\.defaultDatabase) var database

			@Test("Deleting a profile cascades to all owned entities")
			func fullCascade() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						Vehicle.Draft(id: UUID(-3), profileID: UUID(-1), make: "Toyota")
						BankAccount.Draft(id: UUID(-4), profileID: UUID(-1), bankName: "Chase")
						InvestmentAccount.Draft(id: UUID(-5), profileID: UUID(-1), institution: "Vanguard")
						HealthSavingsAccount.Draft(id: UUID(-6), profileID: UUID(-1), accountType: .hsa, institution: "Optum")
						Job.Draft(id: UUID(-7), profileID: UUID(-1), company: "Acme")
						Device.Draft(id: UUID(-8), profileID: UUID(-1), type: .computer, brand: "Apple")
						ServiceProvider.Draft(id: UUID(-9), profileID: UUID(-1), providerType: .internet, name: "Comcast")
						Subscription.Draft(id: UUID(-10), profileID: UUID(-1), name: "Netflix")
						InsurancePolicy.Draft(id: UUID(-11), profileID: UUID(-1), type: .health)
					}
				}

				try await database.write { db in
					try Profile.find(UUID(-1)).delete().execute(db)
				}

				// Verify all entities were cascaded
				let residenceCount = try await database.read { db in try Residence.fetchCount(db) }
				let vehicleCount = try await database.read { db in try Vehicle.fetchCount(db) }
				let bankCount = try await database.read { db in try BankAccount.fetchCount(db) }
				let investCount = try await database.read { db in try InvestmentAccount.fetchCount(db) }
				let hsaCount = try await database.read { db in try HealthSavingsAccount.fetchCount(db) }
				let jobCount = try await database.read { db in try Job.fetchCount(db) }
				let deviceCount = try await database.read { db in try Device.fetchCount(db) }
				let spCount = try await database.read { db in try ServiceProvider.fetchCount(db) }
				let subCount = try await database.read { db in try Subscription.fetchCount(db) }
				let insuranceCount = try await database.read { db in try InsurancePolicy.fetchCount(db) }

				#expect(residenceCount == 0)
				#expect(vehicleCount == 0)
				#expect(bankCount == 0)
				#expect(investCount == 0)
				#expect(hsaCount == 0)
				#expect(jobCount == 0)
				#expect(deviceCount == 0)
				#expect(spCount == 0)
				#expect(subCount == 0)
				#expect(insuranceCount == 0)
			}
		}

		// MARK: - Profile Data Isolation

		@Suite("Data isolation")
		struct DataIsolation {
			@Dependency(\.defaultDatabase) var database

			@Test("Entities from one profile are not visible from another")
			func profileIsolation() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Alice", createdAt: Date(), updatedAt: Date())
						Profile.Draft(id: UUID(-2), name: "Bob", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-3), profileID: UUID(-1), street: "Alice St")
						Vehicle.Draft(id: UUID(-4), profileID: UUID(-1), make: "Toyota")
						Job.Draft(id: UUID(-5), profileID: UUID(-1), company: "Alice Corp")
						Residence.Draft(id: UUID(-6), profileID: UUID(-2), street: "Bob St")
					}
				}

				let bobResidences = try await database.read { db in
					try Residence.where { $0.profileID.eq(UUID(-2)) }.fetchAll(db)
				}
				let bobVehicles = try await database.read { db in
					try Vehicle.where { $0.profileID.eq(UUID(-2)) }.fetchAll(db)
				}
				let bobJobs = try await database.read { db in
					try Job.where { $0.profileID.eq(UUID(-2)) }.fetchAll(db)
				}

				#expect(bobResidences.count == 1)
				let bobResidence = try #require(bobResidences.first)
				#expect(bobResidence.street == "Bob St")
				#expect(bobVehicles.count == 0)
				#expect(bobJobs.count == 0)
			}
		}
	}
}
