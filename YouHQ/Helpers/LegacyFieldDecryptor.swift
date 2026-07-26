//
//  LegacyFieldDecryptor.swift
//  YouHQ
//
//  Created by Ryan Token on 3/1/26.
//

import CryptoKit
import Foundation
import os

/// Reads sensitive fields written by app versions that encrypted them locally before
/// storing them.
///
/// YouHQ no longer encrypts fields itself. CloudKit already encrypts every synced field
/// end to end with keys that only exist in the user's iCloud Keychain, and a second layer
/// of app-managed encryption could not be read by the people a profile was shared with:
/// the key syncs across one Apple Account's devices, never to another person.
///
/// This type only ever *reads*. It loads the old key when the device has one and never
/// generates a new one, so a device that never encrypted anything stays keyless.
/// ``LegacyEncryptedFieldSweep`` uses it to rewrite stored ciphertext as plaintext, and
/// ``LegacySensitiveText`` uses it so values display correctly before the sweep finishes.
///
/// Both this type and its two callers can be deleted once every client has run a version
/// containing the sweep.
nonisolated final class LegacyFieldDecryptor: Sendable {
	static let shared = LegacyFieldDecryptor(key: loadKeyFromKeychain())

	/// `nil` when this device holds no legacy key, which is the normal state for a fresh
	/// install and for anyone reading a profile shared from another Apple Account.
	private let key: SymmetricKey?

	/// The smallest possible AES-GCM payload: a 12-byte nonce plus a 16-byte tag.
	private static let minimumSealedBoxSize = 28

	private static let keychainService = "com.youhq.field-encryption"
	private static let keychainAccount = "symmetric-key"
	private static let logger = Logger(subsystem: "YouHQ", category: "LegacyFieldDecryptor")

	/// Takes the key rather than reading it, so tests can supply their own instead of
	/// depending on whatever happens to be in the Keychain of the machine they run on.
	init(key: SymmetricKey?) {
		self.key = key
		if key == nil {
			Self.logger.info("No legacy encryption key on this device")
		}
	}

	/// Whether the stored text has the shape of a value written by the old encrypted-field
	/// format: base64 holding at least a nonce and a tag.
	///
	/// Real account and policy numbers are far too short to decode to 28 bytes, so this
	/// does not mistake a plaintext value for ciphertext.
	static func isLegacyCiphertext(_ text: String) -> Bool {
		guard let data = Data(base64Encoded: text) else { return false }
		return data.count >= minimumSealedBoxSize
	}

	/// The plaintext behind a legacy encrypted value, or `nil` when this device cannot
	/// authenticate it.
	///
	/// Returning `nil` covers two cases that must never be confused with a real value: the
	/// device holds no key, and the value was encrypted with somebody else's key because it
	/// arrived through a shared profile.
	func decrypt(_ ciphertext: String) -> String? {
		guard
			let key,
			Self.isLegacyCiphertext(ciphertext),
			let data = Data(base64Encoded: ciphertext),
			let sealedBox = try? AES.GCM.SealedBox(combined: data),
			let plaintext = try? AES.GCM.open(sealedBox, using: key)
		else {
			return nil
		}
		return String(data: plaintext, encoding: .utf8)
	}

	// MARK: - Keychain

	private static func loadKeyFromKeychain() -> SymmetricKey? {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: keychainService,
			kSecAttrAccount as String: keychainAccount,
			kSecAttrSynchronizable as String: true,
			kSecReturnData as String: true,
			kSecMatchLimit as String: kSecMatchLimitOne
		]

		var result: AnyObject?
		let status = SecItemCopyMatching(query as CFDictionary, &result)

		guard status == errSecSuccess, let keyData = result as? Data else {
			return nil
		}

		return SymmetricKey(data: keyData)
	}
}
