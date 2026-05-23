//
//  EncryptedRepresentations.swift
//  YouHQ
//
//  Created by Ryan Token on 3/1/26.
//

import Foundation
import SQLiteData

private nonisolated struct InvalidEncryptedDouble: Error {}

/// A `QueryRepresentable` type that transparently encrypts `String` values
/// when writing to the database and decrypts when reading.
///
/// Usage:
/// ```swift
/// @Table struct BankAccount {
///     @Column(as: EncryptedString.self) var accountNumber: String = ""
/// }
/// ```
nonisolated struct EncryptedString: QueryBindable, QueryDecodable, QueryRepresentable {
	var queryOutput: String

	init(queryOutput: String) {
		self.queryOutput = queryOutput
	}

	init?(queryBinding: QueryBinding) {
		guard case .text(let ciphertext) = queryBinding else { return nil }
		self.queryOutput = FieldEncryptor.shared.decrypt(ciphertext)
	}

	var queryBinding: QueryBinding {
		.text(FieldEncryptor.shared.encrypt(queryOutput))
	}

	init(decoder: inout some QueryDecoder) throws {
		let ciphertext = try String(decoder: &decoder)
		self.queryOutput = FieldEncryptor.shared.decrypt(ciphertext)
	}
}

/// A `QueryRepresentable` type that transparently encrypts `Double` values
/// when writing to the database and decrypts when reading.
///
/// The value is converted to a string, encrypted, and stored as TEXT.
///
/// Usage:
/// ```swift
/// @Table struct Job {
///     @Column(as: EncryptedDouble.self) var salary: Double?
/// }
/// ```
nonisolated struct EncryptedDouble: QueryBindable, QueryDecodable, QueryRepresentable {
	var queryOutput: Double

	init(queryOutput: Double) {
		self.queryOutput = queryOutput
	}

	init?(queryBinding: QueryBinding) {
		guard case .text(let ciphertext) = queryBinding else { return nil }
		let decrypted = FieldEncryptor.shared.decrypt(ciphertext)
		guard let value = Double(decrypted) else { return nil }
		self.queryOutput = value
	}

	var queryBinding: QueryBinding {
		let plaintext = String(queryOutput)
		return .text(FieldEncryptor.shared.encrypt(plaintext))
	}

	init(decoder: inout some QueryDecoder) throws {
		let ciphertext = try String(decoder: &decoder)
		let decrypted = FieldEncryptor.shared.decrypt(ciphertext)
		guard let value = Double(decrypted) else {
			// Fall back: maybe it's stored as an unencrypted numeric TEXT from before encryption
			guard let fallback = Double(ciphertext) else {
				throw InvalidEncryptedDouble()
			}
			self.queryOutput = fallback
			return
		}
		self.queryOutput = value
	}
}
