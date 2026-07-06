//
//  CurrencyList.swift
//  YouHQ
//
//  Created by Ryan Token on 7/5/26.
//

import SwiftUI

/// A searchable list of currency options with a leading "Default" row that is
/// hidden while searching. Shared by `CurrencyPicker` (per-record overrides) and
/// `CurrencySettingsView` (the app-wide default); callers supply the current
/// selection, the "Default" row's subtitle, and how to handle a selection.
struct CurrencyList<Header: View>: View {
	let selectedCode: String?
	let defaultSubtitle: String
	let onSelect: (String?) -> Void
	@ViewBuilder let header: Header

	@State private var searchText = ""

	init(
		selectedCode: String?,
		defaultSubtitle: String,
		onSelect: @escaping (String?) -> Void,
		@ViewBuilder header: () -> Header = { EmptyView() }
	) {
		self.selectedCode = selectedCode
		self.defaultSubtitle = defaultSubtitle
		self.onSelect = onSelect
		self.header = header()
	}

	private var filteredCodes: [String] {
		guard searchText.isNotEmpty else { return Currency.allCodes }
		return Currency.allCodes.filter { code in
			code.localizedStandardContains(searchText)
				|| Currency.localizedName(for: code).localizedStandardContains(searchText)
		}
	}

	var body: some View {
		List {
			header

			if searchText.isEmpty {
				Section {
					CurrencyOptionRow(
						title: "Default",
						subtitle: defaultSubtitle,
						isSelected: selectedCode == nil
					) {
						onSelect(nil)
					}
				}
			}

			Section {
				ForEach(filteredCodes, id: \.self) { code in
					CurrencyOptionRow(
						title: code,
						subtitle: Currency.localizedName(for: code),
						isSelected: selectedCode == code
					) {
						onSelect(code)
					}
				}
			}
		}
		.searchable(text: $searchText)
	}
}

#Preview {
	NavigationStack {
		CurrencyList(
			selectedCode: "USD",
			defaultSubtitle: "Follows your device",
			onSelect: { _ in }
		)
		.navigationTitle("Currency")
	}
}
