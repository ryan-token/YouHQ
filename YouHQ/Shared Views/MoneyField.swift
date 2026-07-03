//
//  MoneyField.swift
//  YouHQ
//
//  Created by Ryan Token on 6/9/26.
//

import SwiftUI

/// A form row for entering a monetary amount.
///
/// Uses plain decimal entry (`.number`) rather than a live currency-formatted
/// field. Currency-formatted `TextField`s reformat on every keystroke and
/// mangle input under a non-matching locale (e.g. typing "12" becoming
/// "USD 1.002" in an en-AU locale). The currency a value is denominated in is
/// chosen separately via `CurrencySelectorRow`.
struct MoneyField: View {
	let label: String
	@Binding var amount: Double?

	init(_ label: String, amount: Binding<Double?>) {
		self.label = label
		_amount = amount
	}

	var body: some View {
		LabeledField(label) {
			TextField(
				"",
				value: $amount,
				format: .number.precision(.fractionLength(0...2))
			)
			.multilineTextAlignment(.trailing)
			#if !os(macOS)
				.keyboardType(.decimalPad)
			#endif
		}
	}
}

#Preview {
	Form {
		MoneyField("Monthly Cost", amount: .constant(12))
		MoneyField("Deductible", amount: .constant(nil))
	}
}
