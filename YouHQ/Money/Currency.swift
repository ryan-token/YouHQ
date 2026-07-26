//
//  Currency.swift
//  YouHQ
//
//  Created by Ryan Token on 6/9/26.
//

import SwiftUI

/// Helpers for resolving and describing ISO 4217 currency codes.
///
/// Money records store an optional `currencyCode`. A `nil` value means the
/// record follows the app-wide default (`AppSettings.currencyCode`), which in
/// turn falls back to the device locale when the user hasn't chosen one.
enum Currency {
	/// The currency derived from the device's current locale, falling back to
	/// USD when the locale has no associated currency.
	static var deviceDefault: String {
		Locale.current.currency?.identifier ?? "USD"
	}

	/// Resolves the effective app-wide default currency code, where `nil` means
	/// "follow the device locale".
	static func resolvedDefault(_ appSetting: String?) -> String {
		appSetting ?? deviceDefault
	}

	/// Resolves a money record's currency code, falling back to the app-wide
	/// default when the record has no per-record override.
	static func resolved(_ recordCode: String?, default defaultCode: String) -> String {
		recordCode ?? defaultCode
	}

	/// All currency codes known to the system, sorted alphabetically.
	static let allCodes: [String] = Locale.commonISOCurrencyCodes.sorted()

	/// The localized display name for a currency code, e.g. "Australian Dollar".
	static func localizedName(for code: String) -> String {
		Locale.current.localizedString(forCurrencyCode: code) ?? code
	}

	/// The narrow symbol for a currency code (e.g. "$", "€", "¥"), derived by
	/// formatting a zero value and stripping out the numeric portion. Falls back
	/// to the code itself if no symbol can be determined. Useful for compact
	/// labels (e.g. abbreviated chart axes) where a full format style won't fit.
	static func symbol(for code: String) -> String {
		let formatted = (0 as Decimal).formatted(
			.currency(code: code).presentation(.narrow).precision(.fractionLength(0))
		)
		let stripped =
			formatted
			.filter { !$0.isNumber }
			.trimmingCharacters(in: .whitespaces)
		return stripped.isEmpty ? code : stripped
	}
}

// MARK: - Environment

extension EnvironmentValues {
	/// The app-wide default currency code, resolved from `AppSettings` and the
	/// device locale. Injected near the app root; individual records may still
	/// override it with their own `currencyCode`.
	@Entry var defaultCurrencyCode: String = Currency.deviceDefault
}
