//
//  CurrencyOptionRow.swift
//  YouHQ
//
//  Created by Ryan Token on 6/9/26.
//

import SwiftUI

/// A selectable row showing a currency option (a code with a localized name, or
/// the "Default" choice) and a checkmark when selected. Shared by
/// `CurrencyPicker` and `CurrencySettingsView`.
struct CurrencyOptionRow: View {
	let title: String
	let subtitle: String
	let isSelected: Bool
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			HStack {
				VStack(alignment: .leading, spacing: 2) {
					HQText(title)
					HQText(subtitle)
						.font(.caption)
						.foregroundStyle(.secondary)
				}
				Spacer()
				if isSelected {
					Image(systemName: "checkmark")
						.foregroundStyle(.tint)
				}
			}
			.contentShape(.rect)
		}
		.buttonStyle(.plain)
	}
}
