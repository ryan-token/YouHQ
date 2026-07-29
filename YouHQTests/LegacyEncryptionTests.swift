//
//  LegacyEncryptionTests.swift
//  YouHQTests
//
//  Created by Ryan Token on 3/1/26.
//

import CryptoKit
import Dependencies
import DependenciesTestSupport
import Foundation
import SQLiteData
import Testing

@testable import YouHQ

extension YouHQTests {
	/// Covers reading and retiring the fields that older app versions stored encrypted.
	///
	/// The stakes are lopsided: failing to decrypt a value only hides it, but writing over a
	/// value this device could not read destroys it for everyone sharing the profile. Most of
	/// what follows pins down that second case.
	@Suite("Legacy encryption")
	struct LegacyEncryptionTests {

		// MARK: - Telling ciphertext from real values

		@Suite("Telling ciphertext from real values")
		struct Classification {
			@Test(
				"Real values are never mistaken for ciphertext",
				arguments: [
					"",
					"9876",
					"021000021",
					"HSA-7890",
					"C02X1234ABCD",
					"1HGBH41JXMN109186",
					"policy-1234-5678",
					"UTIL-5678",
					"125000.5",
					"not base64 at all!@#$"
				]
			)
			func realValuesAreNotCiphertext(value: String) {
				#expect(!LegacyFieldDecryptor.isLegacyCiphertext(value))
			}

			@Test("A sealed value is recognized as ciphertext")
			func sealedValueIsCiphertext() throws {
				let ciphertext = try legacyCiphertext(for: "9876", key: SymmetricKey(size: .bits256))
				#expect(LegacyFieldDecryptor.isLegacyCiphertext(ciphertext))
			}
		}

		// MARK: - Reading stored values

		@Suite("Reading stored values")
		struct Reading {
			@Dependency(\.defaultDatabase) var database

			@Test("Plaintext reads through untouched")
			func plaintextReadsThrough() {
				#expect(LegacySensitiveText.readableValue(for: "9876") == "9876")
			}

			@Test("Ciphertext this device cannot read is hidden rather than shown")
			func unreadableCiphertextIsHidden() throws {
				let ciphertext = try legacyCiphertext(for: "9876", key: SymmetricKey(size: .bits256))
				#expect(LegacySensitiveText.readableValue(for: ciphertext).isEmpty)
			}

			@Test("A field encrypted with somebody else's key reads as empty, not as base64")
			func sharedProfileFieldReadsEmpty() async throws {
				try await seedBankAccount(in: database)
				let ciphertext = try legacyCiphertext(for: "9876", key: SymmetricKey(size: .bits256))
				try await setRawValue(ciphertext, column: "accountNumber", in: database)

				let account = try await database.read { db in
					try #require(try BankAccount.find(UUID(-2)).fetchOne(db))
				}
				#expect(account.accountNumber.isEmpty)
			}
		}

		// MARK: - Sweep

		@Suite("Sweep")
		struct Sweep {
			@Dependency(\.defaultDatabase) var database

			@Test("Values this device holds the key for are rewritten as plaintext")
			func rewritesOwnValues() async throws {
				let key = SymmetricKey(size: .bits256)
				try await seedBankAccount(in: database)
				try await setRawValue(
					try legacyCiphertext(for: "9876", key: key),
					column: "accountNumber",
					in: database
				)

				let rewritten = await LegacyEncryptedFieldSweep(
					decryptor: LegacyFieldDecryptor(key: key)
				)
				.run()

				#expect(rewritten == 1)
				let stored = try await rawValue(column: "accountNumber", in: database)
				#expect(stored == "9876")
			}

			/// The sweep addresses its tables by name in raw SQL, so a name that drifts out of
			/// step with the schema fails silently: the write throws, `withErrorReporting`
			/// swallows it, and the run reports nothing converted. Only exercising every entry
			/// catches that, and the rows are seeded through the real model types so the schema
			/// is what the sweep's list is being checked against.
			@Test(
				"Every column the sweep names is converted",
				arguments: [
					("bankAccounts", "accountNumber"),
					("bankAccounts", "routingNumber"),
					("investmentAccounts", "accountNumber"),
					("healthSavingsAccounts", "accountNumber"),
					("insurancePolicies", "policyNumber"),
					("vehicles", "vin"),
					("devices", "serialNumber"),
					("utilities", "accountNumber"),
					("serviceProviders", "accountNumber")
				]
			)
			func convertsEveryNamedColumn(table: String, column: String) async throws {
				let key = SymmetricKey(size: .bits256)
				let id = try #require(seededRowID[table], "no seeded row for \(table)")
				try await seedEncryptedTables(in: database)
				try await setRawValue(
					try legacyCiphertext(for: "secret-value", key: key),
					column: column,
					table: table,
					id: id,
					in: database
				)

				let rewritten = await LegacyEncryptedFieldSweep(
					decryptor: LegacyFieldDecryptor(key: key)
				)
				.run()

				// Every other seeded column is empty or null, so the sweep has exactly one
				// value to convert and the count doubles as proof it found the right one.
				#expect(rewritten == 1, "\(table).\(column) was not converted")
				let stored = try await rawValue(column: column, table: table, id: id, in: database)
				#expect(stored == "secret-value")
			}

			@Test("Values encrypted with somebody else's key are left exactly as they are")
			func leavesSharedValuesAlone() async throws {
				try await seedBankAccount(in: database)
				let ciphertext = try legacyCiphertext(for: "9876", key: SymmetricKey(size: .bits256))
				try await setRawValue(ciphertext, column: "accountNumber", in: database)

				let rewritten = await LegacyEncryptedFieldSweep(
					decryptor: LegacyFieldDecryptor(key: SymmetricKey(size: .bits256))
				)
				.run()

				#expect(rewritten == 0)
				let stored = try await rawValue(column: "accountNumber", in: database)
				#expect(stored == ciphertext)
			}

			@Test("Plaintext is left alone, so the sweep is safe to run on every launch")
			func plaintextSurvivesRepeatedRuns() async throws {
				let key = SymmetricKey(size: .bits256)
				try await seedBankAccount(in: database)
				try await setRawValue(
					try legacyCiphertext(for: "9876", key: key),
					column: "accountNumber",
					in: database
				)

				let sweep = LegacyEncryptedFieldSweep(decryptor: LegacyFieldDecryptor(key: key))
				#expect(await sweep.run() == 1)
				#expect(await sweep.run() == 0)
				let stored = try await rawValue(column: "accountNumber", in: database)
				#expect(stored == "9876")
			}

			@Test("A device with no key rewrites nothing")
			func keylessDeviceRewritesNothing() async throws {
				try await seedBankAccount(in: database)
				let ciphertext = try legacyCiphertext(for: "9876", key: SymmetricKey(size: .bits256))
				try await setRawValue(ciphertext, column: "accountNumber", in: database)

				let rewritten = await LegacyEncryptedFieldSweep(
					decryptor: LegacyFieldDecryptor(key: nil)
				)
				.run()

				#expect(rewritten == 0)
				let stored = try await rawValue(column: "accountNumber", in: database)
				#expect(stored == ciphertext)
			}

			@Test("Salaries move into the plaintext column, and the encrypted one is cleared")
			func movesSalaryToPlaintextColumn() async throws {
				let key = SymmetricKey(size: .bits256)
				try await seedJob(in: database)
				try await setRawValue(
					try legacyCiphertext(for: "125000.5", key: key),
					column: "salaryEncrypted",
					table: "jobs",
					in: database
				)

				let rewritten = await LegacyEncryptedFieldSweep(
					decryptor: LegacyFieldDecryptor(key: key)
				)
				.run()

				#expect(rewritten == 1)
				let job = try await database.read { db in
					try #require(try Job.find(UUID(-2)).fetchOne(db))
				}
				#expect(job.salary == 125_000.5)
				// Cleared, so deleting the salary later cannot be undone by a later sweep.
				let storedCiphertext = try await rawValue(column: "salaryEncrypted", table: "jobs", in: database)
				#expect(storedCiphertext == nil)
			}

			@Test("A pre-encryption plaintext salary is converted even on a keyless device")
			func movesPreEncryptionPlaintextSalary() async throws {
				try await seedJob(in: database)
				try await setRawValue("125000.5", column: "salaryEncrypted", table: "jobs", in: database)

				let rewritten = await LegacyEncryptedFieldSweep(
					decryptor: LegacyFieldDecryptor(key: nil)
				)
				.run()

				#expect(rewritten == 1)
				let job = try await database.read { db in
					try #require(try Job.find(UUID(-2)).fetchOne(db))
				}
				#expect(job.salary == 125_000.5)
				let stored = try await rawValue(column: "salaryEncrypted", table: "jobs", in: database)
				#expect(stored == nil)
			}

			@Test("A salary already converted is not overwritten by stale ciphertext")
			func doesNotOverwriteConvertedSalary() async throws {
				let key = SymmetricKey(size: .bits256)
				try await seedJob(in: database)
				try await database.write { db in
					try Job.find(UUID(-2)).update { $0.salary = #bind(90_000) }.execute(db)
				}
				try await setRawValue(
					try legacyCiphertext(for: "125000.5", key: key),
					column: "salaryEncrypted",
					table: "jobs",
					in: database
				)

				await LegacyEncryptedFieldSweep(decryptor: LegacyFieldDecryptor(key: key)).run()

				let job = try await database.read { db in
					try #require(try Job.find(UUID(-2)).fetchOne(db))
				}
				#expect(job.salary == 90_000)
			}
		}

		// MARK: - Editing a shared record

		@Suite("Editing a shared record")
		struct Editing {
			@Dependency(\.defaultDatabase) var database

			@MainActor
			@Test("Saving without touching an unreadable field leaves the owner's value intact")
			func untouchedFieldIsNotWrittenBack() async throws {
				try await seedBankAccount(in: database)
				let ciphertext = try legacyCiphertext(for: "9876", key: SymmetricKey(size: .bits256))
				try await setRawValue(ciphertext, column: "accountNumber", in: database)

				let account = try await database.read { db in
					try #require(try BankAccount.find(UUID(-2)).fetchOne(db))
				}
				let model = BankAccountEdit.ViewModel(account: account, isNew: false)
				model.bankName = "Chase Sapphire"
				model.save()

				let storedName = try await rawValue(column: "bankName", in: database)
				let storedAccountNumber = try await rawValue(column: "accountNumber", in: database)
				#expect(storedName == "Chase Sapphire")
				#expect(storedAccountNumber == ciphertext)
			}

			@MainActor
			@Test("A field the user does edit is saved as plaintext")
			func editedFieldIsSavedAsPlaintext() async throws {
				try await seedBankAccount(in: database)

				let account = try await database.read { db in
					try #require(try BankAccount.find(UUID(-2)).fetchOne(db))
				}
				let model = BankAccountEdit.ViewModel(account: account, isNew: false)
				model.accountNumber = "5555"
				model.save()

				let stored = try await rawValue(column: "accountNumber", in: database)
				#expect(stored == "5555")
			}
		}
	}
}

// MARK: - Helpers

/// Builds a value in the format older app versions stored: an AES-GCM sealed box, base64
/// encoded.
private func legacyCiphertext(for plaintext: String, key: SymmetricKey) throws -> String {
	let sealedBox = try AES.GCM.seal(Data(plaintext.utf8), using: key)
	return try #require(sealedBox.combined).base64EncodedString()
}

private func seedBankAccount(in database: any DatabaseWriter) async throws {
	try await database.write { db in
		try db.seed {
			Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
			BankAccount.Draft(
				id: UUID(-2),
				profileID: UUID(-1),
				bankName: "Chase",
				accountNumber: "0000"
			)
		}
	}
}

/// The row the coverage test puts ciphertext into, for each table the sweep names.
private let seededRowID: [String: UUID] = [
	"bankAccounts": UUID(-10),
	"investmentAccounts": UUID(-11),
	"healthSavingsAccounts": UUID(-12),
	"insurancePolicies": UUID(-13),
	"vehicles": UUID(-14),
	"devices": UUID(-15),
	"utilities": UUID(-16),
	"serviceProviders": UUID(-17)
]

/// Seeds one row in every table the sweep touches, built from the real model types rather
/// than from the sweep's own list of columns, so the two can be checked against each other.
private func seedEncryptedTables(in database: any DatabaseWriter) async throws {
	try await database.write { db in
		try db.seed {
			Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
			Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
			BankAccount.Draft(id: UUID(-10), profileID: UUID(-1), bankName: "Chase")
			InvestmentAccount.Draft(id: UUID(-11), profileID: UUID(-1), institution: "Vanguard")
			HealthSavingsAccount.Draft(id: UUID(-12), profileID: UUID(-1), institution: "Optum")
			InsurancePolicy.Draft(
				id: UUID(-13),
				profileID: UUID(-1),
				residenceID: nil,
				vehicleID: nil,
				type: .health
			)
			Vehicle.Draft(id: UUID(-14), profileID: UUID(-1), make: "Toyota")
			Device.Draft(id: UUID(-15), profileID: UUID(-1), brand: "Apple")
			Utility.Draft(id: UUID(-16), residenceID: UUID(-2), provider: "Duke Energy")
			ServiceProvider.Draft(id: UUID(-17), profileID: UUID(-1), name: "AT&T")
		}
	}
}

private func seedJob(in database: any DatabaseWriter) async throws {
	try await database.write { db in
		try db.seed {
			Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
			Job.Draft(id: UUID(-2), profileID: UUID(-1), company: "Acme", title: "Engineer")
		}
	}
}

/// Writes straight past the `@Column(as:)` representation, which is the only way to stand up
/// a row that still holds ciphertext.
///
/// `COLLATE NOCASE` because `UUID.uuidString` is uppercase and SQLiteData stores these
/// lowercase, so a plain `=` silently matches nothing for any id whose hex contains a
/// letter — which reads as a missing row rather than as a broken helper.
private func setRawValue(
	_ value: String,
	column: String,
	table: String = "bankAccounts",
	id: UUID = UUID(-2),
	in database: any DatabaseWriter
) async throws {
	try await database.write { db in
		try db.execute(
			sql: "UPDATE \"\(table)\" SET \"\(column)\" = ? WHERE \"id\" = ? COLLATE NOCASE",
			arguments: [value, id.uuidString]
		)
	}
}

private func rawValue(
	column: String,
	table: String = "bankAccounts",
	id: UUID = UUID(-2),
	in database: any DatabaseWriter
) async throws -> String? {
	try await database.read { db in
		try String.fetchOne(
			db,
			sql: "SELECT \"\(column)\" FROM \"\(table)\" WHERE \"id\" = ? COLLATE NOCASE",
			arguments: [id.uuidString]
		)
	}
}
