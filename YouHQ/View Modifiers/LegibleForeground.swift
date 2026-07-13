//
//  LegibleForeground.swift
//  YouHQ
//
//  Created by Ryan Token on 7/3/26.
//

import SwiftUI

extension EnvironmentValues {
	/// The legible foreground color (black or white) for content sitting on the
	/// current colored surface. Set by `legibleForeground(on:)`; falls back to
	/// `.primary` on plain backgrounds.
	@Entry var cardForegroundColor: Color = .primary
}

extension View {
	/// Styles this view's content with whichever of black/white reads legibly on
	/// `backgroundColor`, and publishes that color via `\.cardForegroundColor` so
	/// nested controls (e.g. pill fills) can match it.
	///
	/// Apply to the content *before* the background so the text adapts while the
	/// surface keeps its own color.
	func legibleForeground(on backgroundColor: Color) -> some View {
		modifier(LegibleForegroundModifier(backgroundColor: backgroundColor))
	}
}

private struct LegibleForegroundModifier: ViewModifier {
	let backgroundColor: Color
	@Environment(\.self) private var environment

	func body(content: Content) -> some View {
		let foregroundColor = backgroundColor.legibleForegroundColor(in: environment)

		content
			.foregroundStyle(foregroundColor)
			.environment(\.cardForegroundColor, foregroundColor)
	}
}
