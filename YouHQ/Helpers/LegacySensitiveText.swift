//
//  LegacySensitiveText.swift
//  YouHQ
//
//  Created by Ryan Token on 3/1/26.
//

import Foundation
import SQLiteData

/// A `QueryRepresentable` type for the columns that older app versions stored encrypted.
///
/// Writing always stores plaintext. Reading handles the two kinds of stale ciphertext a
/// device can still encounter while clients update at different times:
///
/// * Ciphertext this device *can* read, because it holds the key that wrote it. That
///   happens when another of the user's own devices is still on an older version and
///   re-encrypted the field. The value decrypts transparently, and
///   ``LegacyEncryptedFieldSweep`` rewrites it as plaintext.
/// * Ciphertext this device *cannot* read, because it belongs to a profile shared from
///   another Apple Account whose key never leaves the owner's devices. The value reads as
///   empty so the interface hides the row, rather than showing base64 to the person the
///   profile was shared with. It is left untouched in storage, and appears as soon as the
///   owner's device uploads plaintext.
///
/// Usage:
/// ```swift
/// @Table struct BankAccount {
///     @Column(as: LegacySensitiveText.self) var accountNumber: String = ""
/// }
/// ```
///
/// This type can be deleted, and its columns changed to plain `String`, once every client
/// has run a version containing the sweep.
nonisolated struct LegacySensitiveText: QueryBindable, QueryDecodable, QueryRepresentable {
	var queryOutput: String

	init(queryOutput: String) {
		self.queryOutput = queryOutput
	}

	// QueryBindable witness invoked by SQLiteData at runtime; not seen by static analysis.
	// periphery:ignore
	init?(queryBinding: QueryBinding) {
		guard case .text(let stored) = queryBinding else { return nil }
		self.queryOutput = Self.readableValue(for: stored)
	}

	var queryBinding: QueryBinding {
		.text(queryOutput)
	}

	init(decoder: inout some QueryDecoder) throws {
		self.queryOutput = Self.readableValue(for: try String(decoder: &decoder))
	}

	/// Plaintext passes through untouched. Legacy ciphertext is decrypted when possible and
	/// hidden when not.
	///
	/// A stored value is only treated as ciphertext when it decodes from base64 to at least
	/// a nonce and a tag, which no realistic account, policy, or serial number does. A value
	/// that somehow did would be hidden rather than lost: nothing here writes to the
	/// database, and the edit screens skip fields the user did not change.
	static func readableValue(for stored: String) -> String {
		guard LegacyFieldDecryptor.isLegacyCiphertext(stored) else { return stored }
		return LegacyFieldDecryptor.shared.decrypt(stored) ?? ""
	}
}
