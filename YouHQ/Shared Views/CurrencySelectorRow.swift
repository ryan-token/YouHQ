//
//  CurrencySelectorRow.swift
//  YouHQ
//
//  Created by Ryan Token on 6/9/26.
//

import SwiftUI

/// A form row that lets the user choose the currency a record's amounts are
/// denominated in. A `nil` binding value means "follow the app-wide default
/// currency" (resolved from `AppSettings` and the device locale).
struct CurrencySelectorRow: View {
	@Binding var currencyCode: String?
	@Environment(\.defaultCurrencyCode) private var defaultCurrencyCode
	@State private var isPresentingPicker = false

	private var displayLabel: String {
		currencyCode ?? "Default (\(defaultCurrencyCode))"
	}

	var body: some View {
		LabeledField("Currency") {
			Button {
				isPresentingPicker = true
			} label: {
				HStack(spacing: 4) {
					HQText(displayLabel)
						.lineLimit(1)
					Image(systemName: "chevron.up.chevron.down")
						.font(.caption)
				}
				.foregroundStyle(.secondary)
			}
			.buttonStyle(.plain)
		}
		.sheet(isPresented: $isPresentingPicker) {
			CurrencyPicker(selection: $currencyCode)
		}
	}
}

#Preview {
	Form {
		CurrencySelectorRow(currencyCode: .constant(nil))
		CurrencySelectorRow(currencyCode: .constant("USD"))
	}
}
