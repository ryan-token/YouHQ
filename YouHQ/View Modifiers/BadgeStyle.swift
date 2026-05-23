//
//  BadgeStyle.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import SwiftUI

enum BadgeType {
	case success
	case warning
	case alert
}

struct BadgeStyle: ViewModifier {
	let type: BadgeType

	var backgroundColor: Color {
		switch type {
		case .success:
			.green
		case .warning:
			.orange
		case .alert:
			.red
		}
	}

	func body(content: Content) -> some View {
		content
			.padding(.vertical, 4)
			.padding(.horizontal, 12)
			.background(backgroundColor)
			.clipShape(.capsule)
	}
}

extension View {
	func badgeStyle(type: BadgeType) -> some View {
		modifier(BadgeStyle(type: type))
	}
}
