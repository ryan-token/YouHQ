//
//  CurrencyTests.swift
//  YouHQTests
//
//  Created by Ryan Token on 7/3/26.
//

import Foundation
import Testing

@testable import YouHQ

extension YouHQTests {
	@Suite("Currency")
	struct CurrencyTests {
		@Suite("resolvedDefault")
		struct ResolvedDefault {
			@Test("A concrete app setting wins")
			func usesAppSetting() {
				#expect(Currency.resolvedDefault("EUR") == "EUR")
			}

			@Test("nil falls back to the device default")
			func fallsBackToDeviceDefault() {
				#expect(Currency.resolvedDefault(nil) == Currency.deviceDefault)
			}
		}

		@Suite("deviceDefault")
		struct DeviceDefault {
			@Test("Is a three-letter ISO 4217 code")
			func isThreeLetterCode() {
				let code = Currency.deviceDefault
				#expect(code.count == 3)
				#expect(code == code.uppercased())
			}
		}

		@Suite("symbol(for:)")
		struct Symbol {
			@Test(
				"Returns the expected narrow symbol for major currencies",
				arguments: [
					("USD", "$"),
					("EUR", "€"),
					("GBP", "£"),
					("JPY", "¥")
				] as [(String, String)]
			)
			func majorCurrencySymbols(code: String, symbol: String) {
				#expect(Currency.symbol(for: code).contains(symbol))
			}

			@Test("Falls back to a non-empty value for an unknown code")
			func unknownCodeFallback() {
				#expect(Currency.symbol(for: "XXX").isEmpty == false)
			}
		}

		@Suite("allCodes")
		struct AllCodes {
			@Test("Is sorted, non-empty, and includes common currencies")
			func sortedAndPopulated() {
				let codes = Currency.allCodes
				#expect(codes.isEmpty == false)
				#expect(codes == codes.sorted())
				#expect(codes.contains("USD"))
				#expect(codes.contains("EUR"))
			}
		}

		@Suite("localizedName(for:)")
		struct LocalizedName {
			@Test("Returns a non-empty name for a known code")
			func knownCode() {
				#expect(Currency.localizedName(for: "USD").isEmpty == false)
			}

			@Test("Falls back to the code itself when no name exists")
			func unknownCodeReturnsCode() {
				#expect(Currency.localizedName(for: "ZZZ") == "ZZZ")
			}
		}
	}
}
