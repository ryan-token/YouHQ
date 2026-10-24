//
//  CurrencyOptionRow.swift
//  YouHQ
//
//  Created by Ryan Token on 6/9/26.
//

import SwiftUI

/// The label for a currency option (a code with a localized name, or the
/// "Default" choice) with a checkmark when selected. `CurrencyList` wraps it in
/// the button that makes the selection.
struct CurrencyOptionRow: View {
	let title: String
	let subtitle: String
	let isSelected: Bool

	var body: some View {
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
					.accessibilityHidden(true)
			}
		}
		.contentShape(.rect)
		.accessibilityElement(children: .combine)
		.accessibilityAddTraits(isSelected ? .isSelected : [])
	}
}
