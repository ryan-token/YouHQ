//
//  EncryptionTests.swift
//  YouHQTests
//
//  Created by Ryan Token on 3/1/26.
//

import Dependencies
import DependenciesTestSupport
import Foundation
import SQLiteData
import Testing

@testable import YouHQ

extension YouHQTests {
	@Suite("Encryption")
	struct EncryptionTests {

		// MARK: - FieldEncryptor

		@Suite("FieldEncryptor")
		struct FieldEncryptorTests {
			let encryptor = FieldEncryptor.shared

			@Test("Encrypt and decrypt round-trips a string")
			func roundTrip() {
				let plaintext = "1234-5678-9012"
				let encrypted = encryptor.encrypt(plaintext)
				let decrypted = encryptor.decrypt(encrypted)
				#expect(decrypted == plaintext)
			}

			@Test("Encrypted output differs from plaintext")
			func encryptedDiffersFromPlaintext() {
				let plaintext = "secret-account-number"
				let encrypted = encryptor.encrypt(plaintext)
				#expect(encrypted != plaintext)
			}

			@Test("Encrypted output is valid base64")
			func encryptedIsBase64() {
				let encrypted = encryptor.encrypt("test-value")
				let decoded = Data(base64Encoded: encrypted)
				#expect(decoded != nil)
			}

			@Test("Empty string encrypts to empty string")
			func emptyStringEncrypt() {
				#expect(encryptor.encrypt("") == "")
			}

			@Test("Empty string decrypts to empty string")
			func emptyStringDecrypt() {
				#expect(encryptor.decrypt("") == "")
			}

			@Test("Decrypting non-base64 returns the input unchanged")
			func decryptNonBase64ReturnsInput() {
				let plaintext = "not base64 at all!@#$"
				#expect(encryptor.decrypt(plaintext) == plaintext)
			}

			@Test("Encrypting the same value twice produces identical ciphertexts")
			func deterministicEncryption() {
				let plaintext = "same-value"
				let first = encryptor.encrypt(plaintext)
				let second = encryptor.encrypt(plaintext)
				#expect(first == second)
				#expect(encryptor.decrypt(first) == plaintext)
			}

			@Test("Different plaintexts produce different ciphertexts")
			func differentPlaintextsDiffer() {
				let a = encryptor.encrypt("value-a")
				let b = encryptor.encrypt("value-b")
				#expect(a != b)
			}

			@Test("Round-trips special characters")
			func specialCharacters() {
				let values = [
					"résumé café",
					"日本語テスト",
					"emoji: 🔐🏠💰",
					"line\nbreak\ttab",
					String(repeating: "a", count: 10_000),
				]
				for value in values {
					let decrypted = encryptor.decrypt(encryptor.encrypt(value))
					#expect(decrypted == value)
				}
			}
		}

		// MARK: - Database round-trip

		@Suite("Database round-trip")
		struct DatabaseRoundTrip {
			@Dependency(\.defaultDatabase) var database

			@Test("Bank account numbers are encrypted at rest and decrypted on read")
			func bankAccountEncryption() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						BankAccount.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							bankName: "Chase",
							accountNumber: "9876",
							routingNumber: "021000021"
						)
					}
				}

				let account = try await database.read { db in
					try #require(try BankAccount.find(UUID(-2)).fetchOne(db))
				}
				#expect(account.accountNumber == "9876")
				#expect(account.routingNumber == "021000021")

				// Verify raw storage is encrypted (not plaintext)
				let rawAccountNumber = try await database.read { db in
					try String.fetchOne(
						db,
						sql: "SELECT accountNumber FROM bankAccounts WHERE id = ?",
						arguments: [UUID(-2).uuidString]
					)
				}
				let raw = try #require(rawAccountNumber)
				#expect(raw != "9876")
				#expect(Data(base64Encoded: raw) != nil)
			}

			@Test("Investment account number round-trips through database")
			func investmentAccountEncryption() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						InvestmentAccount.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							institution: "Vanguard",
							accountNumber: "4455"
						)
					}
				}

				let account = try await database.read { db in
					try #require(try InvestmentAccount.find(UUID(-2)).fetchOne(db))
				}
				#expect(account.accountNumber == "4455")
			}

			@Test("HSA account number round-trips through database")
			func hsaEncryption() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						HealthSavingsAccount.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							accountType: .hsa,
							institution: "Optum",
							accountNumber: "HSA-7890"
						)
					}
				}

				let account = try await database.read { db in
					try #require(try HealthSavingsAccount.find(UUID(-2)).fetchOne(db))
				}
				#expect(account.accountNumber == "HSA-7890")
			}

			@Test("Service provider account number round-trips through database")
			func serviceProviderEncryption() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						ServiceProvider.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							name: "AT&T",
							accountNumber: "SP-1234"
						)
					}
				}

				let provider = try await database.read { db in
					try #require(try ServiceProvider.find(UUID(-2)).fetchOne(db))
				}
				#expect(provider.accountNumber == "SP-1234")
			}

			@Test("Device serial number round-trips through database")
			func deviceEncryption() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Device.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							brand: "Apple",
							model: "MacBook Pro",
							serialNumber: "C02X1234ABCD"
						)
					}
				}

				let device = try await database.read { db in
					try #require(try Device.find(UUID(-2)).fetchOne(db))
				}
				#expect(device.serialNumber == "C02X1234ABCD")
			}

			@Test("Utility account number round-trips through database")
			func utilityEncryption() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						Utility.Draft(
							id: UUID(-3),
							residenceID: UUID(-2),
							provider: "Duke Energy",
							accountNumber: "UTIL-5678"
						)
					}
				}

				let utility = try await database.read { db in
					try #require(try Utility.find(UUID(-3)).fetchOne(db))
				}
				#expect(utility.accountNumber == "UTIL-5678")
			}

			@Test("Insurance policy number round-trips through database")
			func insuranceEncryption() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						InsurancePolicy.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							type: .health,
							provider: "Aetna",
							policyNumber: "POL-99887766"
						)
					}
				}

				let policy = try await database.read { db in
					try #require(try InsurancePolicy.find(UUID(-2)).fetchOne(db))
				}
				#expect(policy.policyNumber == "POL-99887766")
			}

			@Test("Vehicle VIN round-trips through database (optional field)")
			func vehicleVINEncryption() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Vehicle.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							make: "Toyota",
							model: "Camry",
							vin: "1HGBH41JXMN109186"
						)
					}
				}

				let vehicle = try await database.read { db in
					try #require(try Vehicle.find(UUID(-2)).fetchOne(db))
				}
				#expect(vehicle.vin == "1HGBH41JXMN109186")

				// Verify raw VIN is encrypted
				let rawVIN = try await database.read { db in
					try String.fetchOne(
						db,
						sql: "SELECT vin FROM vehicles WHERE id = ?",
						arguments: [UUID(-2).uuidString]
					)
				}
				let raw = try #require(rawVIN)
				#expect(raw != "1HGBH41JXMN109186")
			}

			@Test("Nil VIN stays nil in database")
			func nilVINStaysNil() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Vehicle.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							make: "Honda"
						)
					}
				}

				let vehicle = try await database.read { db in
					try #require(try Vehicle.find(UUID(-2)).fetchOne(db))
				}
				#expect(vehicle.vin == nil)
			}

			@Test("Job salary round-trips through database (optional Double)")
			func jobSalaryEncryption() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Job.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							company: "Acme",
							title: "Engineer",
							salary: 125_000.50
						)
					}
				}

				let job = try await database.read { db in
					try #require(try Job.find(UUID(-2)).fetchOne(db))
				}
				#expect(job.salary == 125_000.50)

				// Verify raw salary is encrypted text, not a number
				let rawSalary = try await database.read { db in
					try String.fetchOne(
						db,
						sql: "SELECT salary FROM jobs WHERE id = ?",
						arguments: [UUID(-2).uuidString]
					)
				}
				let raw = try #require(rawSalary)
				#expect(raw != "125000.5")
				#expect(Data(base64Encoded: raw) != nil)
			}

			@Test("Nil salary stays nil in database")
			func nilSalaryStaysNil() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Job.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							company: "Acme",
							title: "Intern"
						)
					}
				}

				let job = try await database.read { db in
					try #require(try Job.find(UUID(-2)).fetchOne(db))
				}
				#expect(job.salary == nil)
			}

			@Test("Empty encrypted string stores as empty in database")
			func emptyEncryptedString() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						BankAccount.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							bankName: "Chase",
							accountNumber: "",
							routingNumber: ""
						)
					}
				}

				let account = try await database.read { db in
					try #require(try BankAccount.find(UUID(-2)).fetchOne(db))
				}
				#expect(account.accountNumber == "")
				#expect(account.routingNumber == "")
			}

			@Test("Updating an encrypted field persists correctly")
			func updateEncryptedField() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						BankAccount.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							bankName: "Chase",
							accountNumber: "1111"
						)
					}
				}

				try await database.write { db in
					try BankAccount.find(UUID(-2))
						.update {
							$0.accountNumber = #bind("2222")
						}
						.execute(db)
				}

				let account = try await database.read { db in
					try #require(try BankAccount.find(UUID(-2)).fetchOne(db))
				}
				#expect(account.accountNumber == "2222")
			}

			@Test("Multiple encrypted fields on the same record round-trip independently")
			func multipleFieldsIndependent() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						BankAccount.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							bankName: "Chase",
							accountNumber: "acct-1234",
							routingNumber: "rout-5678"
						)
					}
				}

				// Verify both fields are encrypted in raw storage
				let (rawAccount, rawRouting) = try await database.read { db in
					let acct = try String.fetchOne(
						db,
						sql: "SELECT accountNumber FROM bankAccounts WHERE id = ?",
						arguments: [UUID(-2).uuidString]
					)
					let rout = try String.fetchOne(
						db,
						sql: "SELECT routingNumber FROM bankAccounts WHERE id = ?",
						arguments: [UUID(-2).uuidString]
					)
					return (acct, rout)
				}
				let rawAcct = try #require(rawAccount)
				let rawRout = try #require(rawRouting)
				#expect(rawAcct != "acct-1234")
				#expect(rawRout != "rout-5678")

				// Both decrypt to their original values
				let account = try await database.read { db in
					try #require(try BankAccount.find(UUID(-2)).fetchOne(db))
				}
				#expect(account.accountNumber == "acct-1234")
				#expect(account.routingNumber == "rout-5678")
			}
		}
	}
}
