//
//  BackgroundColorTests.swift
//  YouHQTests
//
//  Created by Ryan Token on 2/21/26.
//

import Dependencies
import DependenciesTestSupport
import Foundation
import SQLiteData
import SwiftUI
import Testing

@testable import YouHQ

extension YouHQTests {
	@Suite("Background color updates")
	struct BackgroundColorTests {
		@Dependency(\.defaultDatabase) var database

		@Test("Job updateBackgroundColor persists color to database")
		func jobBackgroundColor() async throws {
			try await database.write { db in
				try db.seed {
					Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					Job.Draft(id: UUID(-2), profileID: UUID(-1), company: "Acme", backgroundColor: "blue")
				}
			}

			let job = try await database.read { db in
				try Job.find(UUID(-2)).fetchOne(db)
			}
			let fetched = try #require(job)
			let vm = JobViewModel()
			vm.updateBackgroundColor(.red, for: fetched)

			let updated = try await database.read { db in
				try Job.find(UUID(-2)).fetchOne(db)
			}
			#expect(updated?.backgroundColor == "red")
		}

		@Test("Utility updateBackgroundColor persists color to database")
		func utilityBackgroundColor() async throws {
			try await database.write { db in
				try db.seed {
					Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
					Utility.Draft(
						id: UUID(-3),
						residenceID: UUID(-2),
						backgroundColor: "blue"
					)
				}
			}

			let utility = try await database.read { db in
				try Utility.find(UUID(-3)).fetchOne(db)
			}
			let fetched = try #require(utility)
			let vm = UtilityViewModel()
			vm.updateBackgroundColor(.green, for: fetched)

			let updated = try await database.read { db in
				try Utility.find(UUID(-3)).fetchOne(db)
			}
			#expect(updated?.backgroundColor == "green")
		}

		@Test("Device updateBackgroundColor persists color to database")
		func deviceBackgroundColor() async throws {
			try await database.write { db in
				try db.seed {
					Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					Device.Draft(id: UUID(-2), profileID: UUID(-1), backgroundColor: "pink")
				}
			}

			let device = try await database.read { db in
				try Device.find(UUID(-2)).fetchOne(db)
			}
			let fetched = try #require(device)
			let vm = DeviceViewModel()
			vm.updateBackgroundColor(.purple, for: fetched)

			let updated = try await database.read { db in
				try Device.find(UUID(-2)).fetchOne(db)
			}
			#expect(updated?.backgroundColor == "purple")
		}

		@Test("ServiceProvider updateBackgroundColor persists color to database")
		func serviceProviderBackgroundColor() async throws {
			try await database.write { db in
				try db.seed {
					Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					ServiceProvider.Draft(id: UUID(-2), profileID: UUID(-1), backgroundColor: "purple")
				}
			}

			let sp = try await database.read { db in
				try ServiceProvider.find(UUID(-2)).fetchOne(db)
			}
			let fetched = try #require(sp)
			let vm = ServiceProviderViewModel()
			vm.updateBackgroundColor(.orange, for: fetched)

			let updated = try await database.read { db in
				try ServiceProvider.find(UUID(-2)).fetchOne(db)
			}
			#expect(updated?.backgroundColor == "orange")
		}

		@Test("Subscription updateBackgroundColor persists color to database")
		func subscriptionBackgroundColor() async throws {
			try await database.write { db in
				try db.seed {
					Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					Subscription.Draft(id: UUID(-2), profileID: UUID(-1), backgroundColor: "orange")
				}
			}

			let sub = try await database.read { db in
				try Subscription.find(UUID(-2)).fetchOne(db)
			}
			let fetched = try #require(sub)
			let vm = SubscriptionViewModel()
			vm.updateBackgroundColor(.teal, for: fetched)

			let updated = try await database.read { db in
				try Subscription.find(UUID(-2)).fetchOne(db)
			}
			#expect(updated?.backgroundColor == "teal")
		}

		@Test("BankAccount updateBackgroundColor persists color to database")
		func bankAccountBackgroundColor() async throws {
			try await database.write { db in
				try db.seed {
					Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					BankAccount.Draft(id: UUID(-2), profileID: UUID(-1), backgroundColor: "green")
				}
			}

			let account = try await database.read { db in
				try BankAccount.find(UUID(-2)).fetchOne(db)
			}
			let fetched = try #require(account)
			let vm = BankAccountViewModel()
			vm.updateBackgroundColor(.cyan, for: fetched)

			let updated = try await database.read { db in
				try BankAccount.find(UUID(-2)).fetchOne(db)
			}
			#expect(updated?.backgroundColor == "cyan")
		}

		@Test("InvestmentAccount updateBackgroundColor persists color to database")
		func investmentAccountBackgroundColor() async throws {
			try await database.write { db in
				try db.seed {
					Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					InvestmentAccount.Draft(id: UUID(-2), profileID: UUID(-1), backgroundColor: "mint")
				}
			}

			let account = try await database.read { db in
				try InvestmentAccount.find(UUID(-2)).fetchOne(db)
			}
			let fetched = try #require(account)
			let vm = InvestmentAccountViewModel()
			vm.updateBackgroundColor(.brown, for: fetched)

			let updated = try await database.read { db in
				try InvestmentAccount.find(UUID(-2)).fetchOne(db)
			}
			#expect(updated?.backgroundColor == "brown")
		}

		@Test("HealthSavingsAccount updateBackgroundColor persists color to database")
		func hsaBackgroundColor() async throws {
			try await database.write { db in
				try db.seed {
					Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					HealthSavingsAccount.Draft(id: UUID(-2), profileID: UUID(-1), backgroundColor: "cyan")
				}
			}

			let account = try await database.read { db in
				try HealthSavingsAccount.find(UUID(-2)).fetchOne(db)
			}
			let fetched = try #require(account)
			let vm = HealthSavingsAccountViewModel()
			vm.updateBackgroundColor(.yellow, for: fetched)

			let updated = try await database.read { db in
				try HealthSavingsAccount.find(UUID(-2)).fetchOne(db)
			}
			#expect(updated?.backgroundColor == "yellow")
		}

		@Test("InsurancePolicy updateBackgroundColor persists color to database")
		func insurancePolicyBackgroundColor() async throws {
			try await database.write { db in
				try db.seed {
					Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					InsurancePolicy.Draft(
						id: UUID(-2),
						profileID: UUID(-1),
						type: .health,
						backgroundColor: "red"
					)
				}
			}

			let policy = try await database.read { db in
				try InsurancePolicy.find(UUID(-2)).fetchOne(db)
			}
			let fetched = try #require(policy)
			let vm = InsurancePolicyViewModel()
			vm.updateBackgroundColor(.indigo, for: fetched)

			let updated = try await database.read { db in
				try InsurancePolicy.find(UUID(-2)).fetchOne(db)
			}
			#expect(updated?.backgroundColor == "indigo")
		}

		@Test("Other updateBackgroundColor persists color to database")
		func otherBackgroundColor() async throws {
			try await database.write { db in
				try db.seed {
					Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					Other.Draft(
						id: UUID(-2),
						profileID: UUID(-1),
						category: .career,
						name: "Test",
						backgroundColor: "gray"
					)
				}
			}

			let other = try await database.read { db in
				try Other.find(UUID(-2)).fetchOne(db)
			}
			let fetched = try #require(other)
			let vm = OtherItemViewModel()
			vm.updateBackgroundColor(.mint, for: fetched)

			let updated = try await database.read { db in
				try Other.find(UUID(-2)).fetchOne(db)
			}
			#expect(updated?.backgroundColor == "mint")
		}
	}
}
