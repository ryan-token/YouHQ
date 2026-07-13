//
//  Double+Currency.swift
//  YouHQ
//
//  Created by Ryan Token on 1/2/26.
//

import Foundation

extension Double {
	/// Formats the amount as a currency string using the given ISO 4217 code.
	///
	/// The currency's own conventions determine the symbol, placement, and
	/// number of fraction digits (e.g. `$1,200.00` for USD, `¥1,200` for JPY),
	/// while the device locale determines grouping and how foreign currencies
	/// are presented (e.g. `USD 12.00` for a US dollar value in an en-AU locale).
	func formatted(currencyCode: String) -> String {
		formatted(.currency(code: currencyCode))
	}
}
