//
//  MoneyTests.swift
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
	@Suite("Money")
	struct MoneyTests {

		@Suite("Bank accounts")
		struct BankAccounts {
			@Dependency(\.defaultDatabase) var database

			@Test("Load fetches bank accounts for a profile")
			func loadBankAccounts() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						BankAccount.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							bankName: "Chase",
							accountType: .checking
						)
						BankAccount.Draft(
							id: UUID(-3),
							profileID: UUID(-1),
							bankName: "Ally",
							accountType: .savings
						)
					}
				}

				let vm = BankAccountViewModel()
				await vm.load(for: UUID(-1))

				#expect(vm.bankAccounts.count == 2)
			}

			@Test("Create draft has correct defaults")
			func createDraft() {
				let vm = BankAccountViewModel()
				let draft = vm.createDraft(for: UUID(-1))

				#expect(draft.profileID == UUID(-1))
				#expect(draft.accountType == .checking)
				#expect(draft.bankName == "")
			}

			@Test("Delete removes bank account from database")
			func deleteBankAccount() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						BankAccount.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							bankName: "Chase",
							accountType: .checking
						)
					}
				}

				let vm = BankAccountViewModel()
				await vm.load(for: UUID(-1))
				#expect(vm.bankAccounts.count == 1)

				let first = try #require(vm.bankAccounts.first)
				vm.delete(first)

				let remaining = try await database.read { db in
					try BankAccount.fetchCount(db)
				}
				#expect(remaining == 0)
			}
		}

		// MARK: - InvestmentAccountViewModel Tests

		@Suite("Investment accounts")
		struct InvestmentAccounts {
			@Dependency(\.defaultDatabase) var database

			@Test("Load fetches investment accounts for a profile")
			func loadAccounts() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						InvestmentAccount.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							institution: "Vanguard",
							accountType: .rothIRA
						)
					}
				}

				let vm = InvestmentAccountViewModel()
				await vm.load(for: UUID(-1))

				#expect(vm.investmentAccounts.count == 1)
			}

			@Test("Create draft has correct defaults")
			func createDraft() {
				let vm = InvestmentAccountViewModel()
				let draft = vm.createDraft(for: UUID(-1))

				#expect(draft.profileID == UUID(-1))
				#expect(draft.accountType == .brokerage)
				#expect(draft.institution == "")
			}

			@Test("Delete removes investment account from database")
			func deleteAccount() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						InvestmentAccount.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							institution: "Fidelity",
							accountType: .traditional401k
						)
					}
				}

				let vm = InvestmentAccountViewModel()
				await vm.load(for: UUID(-1))
				let first = try #require(vm.investmentAccounts.first)
				vm.delete(first)

				let remaining = try await database.read { db in
					try InvestmentAccount.fetchCount(db)
				}
				#expect(remaining == 0)
			}
		}

		// MARK: - HealthSavingsAccountViewModel Tests

		@Suite("Health savings accounts")
		struct HealthSavingsAccounts {
			@Dependency(\.defaultDatabase) var database

			@Test("Load fetches HSA accounts for a profile")
			func loadAccounts() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						HealthSavingsAccount.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							accountType: .hsa,
							institution: "Optum"
						)
					}
				}

				let vm = HealthSavingsAccountViewModel()
				await vm.load(for: UUID(-1))

				#expect(vm.healthSavingsAccounts.count == 1)
			}

			@Test("Create draft defaults to HSA type")
			func createDraft() {
				let vm = HealthSavingsAccountViewModel()
				let draft = vm.createDraft(for: UUID(-1))

				#expect(draft.profileID == UUID(-1))
				#expect(draft.accountType == .hsa)
			}

			@Test("Delete removes HSA from database")
			func deleteAccount() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						HealthSavingsAccount.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							accountType: .fsa,
							institution: "HealthEquity"
						)
					}
				}

				let vm = HealthSavingsAccountViewModel()
				await vm.load(for: UUID(-1))
				let first = try #require(vm.healthSavingsAccounts.first)
				vm.delete(first)

				let remaining = try await database.read { db in
					try HealthSavingsAccount.fetchCount(db)
				}
				#expect(remaining == 0)
			}
		}

		// MARK: - Money Queries

		@Suite("Queries")
		struct Queries {
			@Dependency(\.defaultDatabase) var database

			@Test("Standalone insurance policies exclude residence and vehicle policies")
			func standaloneInsurancePolicies() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						Vehicle.Draft(id: UUID(-3), profileID: UUID(-1), make: "Toyota")
						// Standalone policy (money section)
						InsurancePolicy.Draft(
							id: UUID(-4),
							profileID: UUID(-1),
							residenceID: nil,
							vehicleID: nil,
							type: .health,
							provider: "Aetna"
						)
						// Residence policy
						InsurancePolicy.Draft(
							id: UUID(-5),
							profileID: UUID(-1),
							residenceID: UUID(-2),
							vehicleID: nil,
							type: .renters
						)
						// Vehicle policy
						InsurancePolicy.Draft(
							id: UUID(-6),
							profileID: UUID(-1),
							residenceID: nil,
							vehicleID: UUID(-3),
							type: .auto
						)
					}
				}

				let standalone = try await database.read { db in
					try InsurancePolicy
						.where {
							$0.profileID.eq(UUID(-1))
								.and($0.residenceID.is(nil))
								.and($0.vehicleID.is(nil))
						}
						.fetchAll(db)
				}
				#expect(standalone.count == 1)
				let first = try #require(standalone.first)
				#expect(first.provider == "Aetna")
			}

		}
	}
}
