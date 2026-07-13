//
//  ColorContrastTests.swift
//  YouHQTests
//
//  Created by Ryan Token on 7/3/26.
//

import Foundation
import SwiftUI
import Testing

@testable import YouHQ

extension YouHQTests {
	@Suite("Color+Contrast")
	struct ColorContrastTests {
		@Suite("Relative luminance")
		struct RelativeLuminance {
			private let environment = EnvironmentValues()

			@Test("White is maximally luminous, black is minimal")
			func extremes() {
				let white = Color.white.resolve(in: environment).relativeLuminance
				let black = Color.black.resolve(in: environment).relativeLuminance

				#expect(white > 0.99)
				#expect(black < 0.01)
			}

			@Test("Luminance increases from black through gray to white")
			func ordering() {
				let black = Color.black.resolve(in: environment).relativeLuminance
				let gray = Color.gray.resolve(in: environment).relativeLuminance
				let white = Color.white.resolve(in: environment).relativeLuminance

				#expect(black < gray)
				#expect(gray < white)
			}
		}

		@Suite("Legible foreground color")
		struct LegibleForeground {
			private let environment = EnvironmentValues()

			// Only near-white backgrounds (luminance > 0.75) cross to black;
			// this is where white text becomes genuinely unreadable.
			@Test(
				"Near-white backgrounds get black text",
				arguments: [Color.white, Color(hex: "#F5F5F5")!, Color(hex: "#FAFAFA")!]
			)
			func lightBackgroundsGetBlack(background: Color) {
				#expect(background.legibleForegroundColor(in: environment) == .black)
			}

			// Everything below the threshold keeps white, including the app's
			// mid-bright brand colors (teal is the default vehicle color).
			@Test(
				"Dark and mid-bright backgrounds get white text",
				arguments: [Color.black, .indigo, .blue, .purple, .teal, .mint, .cyan]
			)
			func darkBackgroundsGetWhite(background: Color) {
				#expect(background.legibleForegroundColor(in: environment) == .white)
			}

			@Test("A custom light hex color gets black text")
			func customLightHex() {
				// #F5F5F5 — the kind of near-white custom color that made
				// white text unreadable (YOUHQ-86).
				let background = Color(hex: "#F5F5F5")
				#expect(background?.legibleForegroundColor(in: environment) == .black)
			}

			@Test("A custom dark hex color gets white text")
			func customDarkHex() {
				let background = Color(hex: "#101010")
				#expect(background?.legibleForegroundColor(in: environment) == .white)
			}
		}
	}
}
