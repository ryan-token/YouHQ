//
//  LegacyEncryptedFieldSweep.swift
//  YouHQ
//
//  Created by Ryan Token on 3/1/26.
//

import Dependencies
import Foundation
import SQLiteData

/// Rewrites the fields that older app versions stored encrypted so they hold plaintext
/// again.
///
/// This deliberately runs as an ordinary application write rather than as a migration.
/// SQLiteData installs its sync triggers as *temporary* triggers when the `SyncEngine` is
/// created, which is after migrations have already run, so anything a migration writes is
/// invisible to CloudKit and would never reach the people a profile is shared with. Writing
/// after the sync engine exists is what actually uploads the plaintext.
///
/// It is safe to run on every launch:
///
/// * A value is only touched when it decodes as ciphertext *and* authenticates with this
///   device's key, so the rewritten plaintext is skipped on the next pass.
/// * Values this device cannot authenticate are left exactly as they are. They belong to a
///   profile shared from another Apple Account, and blanking them here would sync the blank
///   back and destroy the owner's data.
///
/// Running repeatedly also heals two cases a one-shot migration would miss: a device whose
/// key had not yet arrived from iCloud Keychain on the first launch, and ciphertext that
/// arrives later from one of the user's own devices still on an older version.
///
/// This type can be deleted once every client has run a version containing it.
nonisolated struct LegacyEncryptedFieldSweep {
	@Dependency(\.defaultDatabase) var database

	private let decryptor: LegacyFieldDecryptor

	init(decryptor: LegacyFieldDecryptor = .shared) {
		self.decryptor = decryptor
	}

	/// Every text column an older version encrypted.
	private static let textColumns: [(table: String, column: String)] = [
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

	/// Decrypts every legacy value this device holds the key for. Returns the number of
	/// values rewritten, which is zero on all but the first run after updating.
	@discardableResult
	func run() async -> Int {
		await withErrorReporting {
			try await database.write { db in
				var rewritten = 0
				for (table, column) in Self.textColumns {
					rewritten += try decryptText(table: table, column: column, db: db)
				}
				rewritten += try decryptSalaries(db: db)
				return rewritten
			}
		} ?? 0
	}

	private func decryptText(table: String, column: String, db: Database) throws -> Int {
		// Table and column names are compile-time constants from `textColumns`, never input.
		let rows = try #sql(
			"""
			SELECT "id", "\(raw: column)" FROM "\(raw: table)"
			WHERE "\(raw: column)" IS NOT NULL AND "\(raw: column)" != ''
			""",
			as: (String, String).self
		)
		.fetchAll(db)

		var rewritten = 0
		for (id, stored) in rows {
			guard let plaintext = decryptor.decrypt(stored) else { continue }
			try #sql(
				"""
				UPDATE "\(raw: table)" SET "\(raw: column)" = \(bind: plaintext)
				WHERE "id" = \(bind: id)
				"""
			)
			.execute(db)
			rewritten += 1
		}
		return rewritten
	}

	/// Moves salaries out of the encrypted `salaryEncrypted` column and into `salaryAmount`.
	///
	/// `salaryEncrypted` is cleared as each row is converted. Without that, a salary the user
	/// later deletes would reappear on the next launch, because the old ciphertext would
	/// still be sitting there waiting to be decrypted again. Clearing it stays local: the
	/// column is no longer part of `Job`, so SQLiteData never uploads it.
	private func decryptSalaries(db: Database) throws -> Int {
		let rows = try #sql(
			"""
			SELECT "id", "salaryEncrypted" FROM "jobs"
			WHERE "salaryEncrypted" IS NOT NULL AND "salaryEncrypted" != ''
			AND "salaryAmount" IS NULL
			""",
			as: (String, String).self
		)
		.fetchAll(db)

		var rewritten = 0
		for (id, stored) in rows {
			guard
				let plaintext = decryptor.decrypt(stored),
				let salary = Double(plaintext)
			else {
				continue
			}
			try #sql(
				"""
				UPDATE "jobs" SET "salaryAmount" = \(bind: salary), "salaryEncrypted" = NULL
				WHERE "id" = \(bind: id)
				"""
			)
			.execute(db)
			rewritten += 1
		}
		return rewritten
	}
}
