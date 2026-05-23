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
		case .red: return "red"
		case .orange: return "orange"
		case .yellow: return "yellow"
		case .green: return "green"
		case .mint: return "mint"
		case .teal: return "teal"
		case .cyan: return "cyan"
		case .blue: return "blue"
		case .indigo: return "indigo"
		case .purple: return "purple"
		case .pink: return "pink"
		case .brown: return "brown"
		case .gray: return "gray"
		default:
			// For custom colors, convert to hex
			return toHex() ?? "indigo"
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
			if let color = Color(hex: databaseValue) {
				self = color
			} else {
				self = .indigo
			}
		}
	}

	/// Converts Color to hex string
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

		return String(format: "#%02X%02X%02X", red, green, blue)
	}

	/// Creates a Color from a hex string
	init?(hex: String) {
		let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
		guard let rgbValue = UInt64(hex, radix: 16) else { return nil }

		let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
		let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
		let blue = Double(rgbValue & 0x0000FF) / 255.0

		self.init(red: red, green: green, blue: blue)
	}
}
