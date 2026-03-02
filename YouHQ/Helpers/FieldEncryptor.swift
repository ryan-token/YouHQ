//
//  FieldEncryptor.swift
//  YouHQ
//
//  Created by Ryan Token on 3/1/26.
//

import CryptoKit
import Foundation
import os

/// Manages AES-GCM encryption of sensitive database fields.
///
/// The symmetric key is stored in the Keychain with iCloud sync enabled,
/// so all devices on the same iCloud account share the same key.
nonisolated final class FieldEncryptor: Sendable {
    static let shared = FieldEncryptor()

    private let key: SymmetricKey

    private static let keychainService = "com.youhq.field-encryption"
    private static let keychainAccount = "symmetric-key"
    private static let logger = Logger(subsystem: "YouHQ", category: "FieldEncryptor")

    private init() {
        if let existingKey = Self.loadKeyFromKeychain() {
            self.key = existingKey
        } else {
            // Key not found — it may be syncing from another device via iCloud
            // Keychain. Retry a few times before generating a new key to avoid
            // creating a second key that would overwrite the original.
            for attempt in 1...3 {
                Self.logger.info("Encryption key not found, retry \(attempt)/3…")
                Thread.sleep(forTimeInterval: 0.5)
                if let syncedKey = Self.loadKeyFromKeychain() {
                    self.key = syncedKey
                    Self.logger.info("Encryption key arrived via iCloud Keychain")
                    return
                }
            }
            let newKey = SymmetricKey(size: .bits256)
            if let existingKey = Self.saveKeyToKeychainUnlessExists(newKey) {
                // A key synced in between our last retry and the save attempt.
                // Use the synced key so all devices share the same key.
                self.key = existingKey
                Self.logger.info("Encryption key arrived via iCloud Keychain (late sync)")
            } else {
                self.key = newKey
                Self.logger.info("Generated new field encryption key")
            }
        }
    }

    // MARK: - Encryption

    func encrypt(_ plaintext: String) -> String {
        guard !plaintext.isEmpty else { return "" }
        let data = Data(plaintext.utf8)
        do {
            // Derive a deterministic nonce from the plaintext using HMAC.
            // Same plaintext + same key always produces the same ciphertext,
            // which is required for CloudKit change detection to work correctly.
            let hmac = HMAC<SHA256>.authenticationCode(for: data, using: key)
            let nonceBytes = Data(hmac.prefix(12))
            let nonce = try AES.GCM.Nonce(data: nonceBytes)
            let sealedBox = try AES.GCM.seal(data, using: key, nonce: nonce)
            return sealedBox.combined!.base64EncodedString()
        } catch {
            Self.logger.error("Encryption failed: \(error.localizedDescription)")
            return plaintext
        }
    }

    func decrypt(_ ciphertext: String) -> String {
        guard !ciphertext.isEmpty else { return "" }
        guard let data = Data(base64Encoded: ciphertext) else {
            // Not base64 — likely unencrypted plaintext from before encryption was added
            return ciphertext
        }
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return String(data: decryptedData, encoding: .utf8) ?? ciphertext
        } catch {
            // Decryption failed — likely unencrypted plaintext from before encryption was added
            return ciphertext
        }
    }

    // MARK: - Keychain

    private static func loadKeyFromKeychain() -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecAttrSynchronizable as String: kCFBooleanTrue!,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let keyData = result as? Data else {
            return nil
        }

        return SymmetricKey(data: keyData)
    }

    /// Saves the key to the Keychain. If a key already exists (e.g. synced from
    /// another device via iCloud Keychain), returns that existing key instead of
    /// overwriting it. Returns `nil` if the new key was saved successfully.
    @discardableResult
    private static func saveKeyToKeychainUnlessExists(_ key: SymmetricKey) -> SymmetricKey? {
        let keyData = key.withUnsafeBytes { Data($0) }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecAttrSynchronizable as String: kCFBooleanTrue!,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecDuplicateItem {
            // A key already exists — it likely synced from another device.
            // Return it so the caller uses the original key instead.
            return loadKeyFromKeychain()
        } else if status != errSecSuccess {
            logger.error("Failed to save encryption key to Keychain: \(status)")
        }
        return nil
    }
}
