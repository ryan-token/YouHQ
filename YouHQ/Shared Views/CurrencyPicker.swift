//
//  CurrencyPicker.swift
//  YouHQ
//
//  Created by Ryan Token on 6/9/26.
//

import SwiftUI

/// A searchable list for choosing a currency. Binding a `nil` selection means
/// "follow the app-wide default currency", offered as the first option.
struct CurrencyPicker: View {
	@Binding var selection: String?
	@Environment(\.defaultCurrencyCode) private var defaultCurrencyCode
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		NavigationStack {
			CurrencyList(
				selectedCode: selection,
				defaultSubtitle: Currency.localizedName(for: defaultCurrencyCode)
			) { code in
				selection = code
				dismiss()
			}
			.navigationTitle("Currency")
			#if !os(macOS)
				.navigationBarTitleDisplayMode(.inline)
			#endif
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") { dismiss() }
				}
			}
		}
	}
}

#Preview {
	CurrencyPicker(selection: .constant("USD"))
}
