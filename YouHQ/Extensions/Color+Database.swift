//
//  Color+Database.swift
//  YouHQ
//
//  Created by Ryan Token on 1/8/26.
//

import SQLiteData
import SwiftUI

extension Color {
	/// Converts a SwiftUI Color to a string for database storage
	/// Uses semantic names for built-in colors, falls back to hex for custom colors
	var databaseValue: String {
		switch self {
		case .red: "red"
		case .orange: "orange"
		case .yellow: "yellow"
		case .green: "green"
		case .mint: "mint"
		case .teal: "teal"
		case .cyan: "cyan"
		case .blue: "blue"
		case .indigo: "indigo"
		case .purple: "purple"
		case .pink: "pink"
		case .brown: "brown"
		case .gray: "gray"
		default:
			// For custom colors, convert to hex
			toHex() ?? "indigo"
		}
	}

	/// Creates a SwiftUI Color from a database string value
	/// Supports semantic color names and hex strings
	init(databaseValue: String) {
		switch databaseValue.lowercased() {
		case "red": self = .red
		case "orange": self = .orange
		case "yellow": self = .yellow
		case "green": self = .green
		case "mint": self = .mint
		case "teal": self = .teal
		case "cyan": self = .cyan
		case "blue": self = .blue
		case "indigo": self = .indigo
		case "purple": self = .purple
		case "pink": self = .pink
		case "brown": self = .brown
		case "gray": self = .gray
		default:
			// Try to parse as hex, fallback to indigo
			self = Color(hex: databaseValue) ?? .indigo
		}
	}

	/// Converts Color to hex string
	///
	/// The result is persisted and synced, so this deliberately keeps reading the platform
	/// color's own `CGColor` components rather than `resolve(in:)`. Resolving converts to
	/// sRGB, which would store different values for colors in other spaces, such as Display P3
	/// from the color picker, and change which colors (like two-component grayscale ones) fall
	/// back to `"indigo"`.
	private func toHex() -> String? {
		#if canImport(UIKit)
			guard let components = UIColor(self).cgColor.components else {
				return nil
			}
		#elseif canImport(AppKit)
			guard let components = NSColor(self).cgColor.components else {
				return nil
			}
		#endif

		guard components.count >= 3 else { return nil }

		let red = Int(components[0] * 255.0)
		let green = Int(components[1] * 255.0)
		let blue = Int(components[2] * 255.0)

		return "#" + Self.hexByte(red) + Self.hexByte(green) + Self.hexByte(blue)
	}

	/// Formats one channel exactly as `String(format: "%02X")` did, so stored values never
	/// change: uppercase, zero-padded to two digits, and reading the low 32 bits as unsigned
	/// for the out-of-range values that extended-range components can produce.
	private static func hexByte(_ value: Int) -> String {
		let digits = String(UInt32(truncatingIfNeeded: value), radix: 16, uppercase: true)
		return digits.count < 2 ? "0" + digits : digits
	}

	/// Creates a Color from a hex string
	nonisolated init?(hex: String) {
		let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
		guard let rgbValue = UInt64(hex, radix: 16) else { return nil }

		let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
		let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
		let blue = Double(rgbValue & 0x0000FF) / 255.0

		self.init(red: red, green: green, blue: blue)
	}
}
