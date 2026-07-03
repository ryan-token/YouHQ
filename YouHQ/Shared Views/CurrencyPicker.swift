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
	@State private var searchText = ""

	private var filteredCodes: [String] {
		guard searchText.isNotEmpty else { return Currency.allCodes }
		return Currency.allCodes.filter { code in
			code.localizedStandardContains(searchText)
				|| Currency.localizedName(for: code).localizedStandardContains(searchText)
		}
	}

	var body: some View {
		NavigationStack {
			List {
				if searchText.isEmpty {
					Section {
						CurrencyOptionRow(
							title: "Default",
							subtitle: Currency.localizedName(for: defaultCurrencyCode),
							isSelected: selection == nil
						) {
							selection = nil
							dismiss()
						}
					}
				}

				Section {
					ForEach(filteredCodes, id: \.self) { code in
						CurrencyOptionRow(
							title: code,
							subtitle: Currency.localizedName(for: code),
							isSelected: selection == code
						) {
							selection = code
							dismiss()
						}
					}
				}
			}
			.searchable(text: $searchText)
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
