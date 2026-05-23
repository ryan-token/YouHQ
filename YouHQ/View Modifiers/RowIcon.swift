//
//  RowIcon.swift
//  YouHQ
//
//  Created by Ryan Token on 1/29/26.
//

import SwiftUI

struct RowIcon: ViewModifier {
	let color: Color

	func body(content: Content) -> some View {
		content
			.font(.title2)
			.foregroundStyle(color)
	}
}

extension View {
	func rowIcon(color: Color) -> some View {
		modifier(RowIcon(color: color))
	}
}
