//
//  ColorDatabaseTests.swift
//  YouHQTests
//
//  Created by Ryan Token on 2/21/26.
//

import Dependencies
import DependenciesTestSupport
import Foundation
import SQLiteData
import SwiftUI
import Testing

@testable import YouHQ

extension YouHQTests {
	@Suite("Color+Database")
	struct ColorDatabaseTests {
		@Suite("Semantic color round-trip")
		struct SemanticRoundTrip {
			@Test(
				"Known colors survive databaseValue → init(databaseValue:) round-trip",
				arguments: [
					("red", Color.red),
					("orange", Color.orange),
					("yellow", Color.yellow),
					("green", Color.green),
					("mint", Color.mint),
					("teal", Color.teal),
					("cyan", Color.cyan),
					("blue", Color.blue),
					("indigo", Color.indigo),
					("purple", Color.purple),
					("pink", Color.pink),
					("brown", Color.brown),
					("gray", Color.gray),
				]
			)
			func semanticRoundTrip(expected: String, color: Color) {
				let dbValue = color.databaseValue
				#expect(dbValue == expected)

				let restored = Color(databaseValue: dbValue)
				#expect(restored == color)
			}
		}

		@Suite("Hex parsing")
		struct HexParsing {
			@Test("Valid hex string with hash creates a color")
			func validHexWithHash() {
				let color = Color(hex: "#FF0000")
				#expect(color != nil)
			}

			@Test("Valid hex string without hash creates a color")
			func validHexWithoutHash() {
				let color = Color(hex: "00FF00")
				#expect(color != nil)
			}

			@Test("Invalid hex string returns nil")
			func invalidHex() {
				let color = Color(hex: "notacolor")
				#expect(color == nil)
			}

			@Test("Empty hex string returns nil")
			func emptyHex() {
				let color = Color(hex: "")
				#expect(color == nil)
			}
		}

		@Suite("Fallback behavior")
		struct Fallback {
			@Test("Unknown database value falls back to indigo")
			func unknownFallsBackToIndigo() {
				let color = Color(databaseValue: "nonexistent")
				#expect(color == .indigo)
			}

			@Test("Empty database value falls back to indigo")
			func emptyFallsBackToIndigo() {
				let color = Color(databaseValue: "")
				#expect(color == .indigo)
			}

			@Test("Case-insensitive lookup works")
			func caseInsensitive() {
				let color = Color(databaseValue: "RED")
				#expect(color == .red)
			}

			@Test("Mixed case lookup works")
			func mixedCase() {
				let color = Color(databaseValue: "Blue")
				#expect(color == .blue)
			}
		}

		@Suite("Hex database value")
		struct HexDatabaseValue {
			@Test("Hex database value round-trips via init(databaseValue:)")
			func hexRoundTrip() {
				let original = Color(databaseValue: "#FF8800")
				let dbValue = original.databaseValue
				let restored = Color(databaseValue: dbValue)

				// Both should produce the same databaseValue
				#expect(original.databaseValue == restored.databaseValue)
			}
		}
	}
}
