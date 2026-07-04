//
//  Color+Contrast.swift
//  YouHQ
//
//  Created by Ryan Token on 7/3/26.
//

import SwiftUI

extension Color.Resolved {
	/// The WCAG relative luminance of the color, in the range `0` (black) to `1` (white).
	///
	/// Computed from the linear sRGB components, which is what the WCAG contrast
	/// model expects. See https://www.w3.org/TR/WCAG21/#dfn-relative-luminance.
	var relativeLuminance: Double {
		0.2126 * Double(linearRed)
			+ 0.7152 * Double(linearGreen)
			+ 0.0722 * Double(linearBlue)
	}
}

extension Color {
	/// The color — black or white — that reads legibly on top of this color.
	///
	/// Colors brighter than the luminance threshold get black text; everything
	/// else gets white. The threshold (`0.75`) sits above the WCAG contrast
	/// crossover (~0.179) so that white text is preferred on all but genuinely
	/// light backgrounds, matching the app's visual style.
	///
	/// - Parameter environment: The environment used to resolve this color to concrete
	///   RGB components (needed because a `Color` may be dynamic, e.g. asset colors).
	func legibleForegroundColor(in environment: EnvironmentValues) -> Color {
		resolve(in: environment).relativeLuminance > 0.75 ? .black : .white
	}
}
