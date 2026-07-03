//
//  CurrencySettingsView.swift
//  YouHQ
//
//  Created by Ryan Token on 6/9/26.
//

import SwiftUI

/// Lets the user choose the app-wide default currency. Individual records can
/// still override this from their own edit screens. "Default" follows the
/// device locale.
struct CurrencySettingsView: View {
	@State private var viewModel = ViewModel()
	@State private var searchText = ""

	private var filteredCodes: [String] {
		guard searchText.isNotEmpty else { return Currency.allCodes }
		return Currency.allCodes.filter { code in
			code.localizedStandardContains(searchText)
				|| Currency.localizedName(for: code).localizedStandardContains(searchText)
		}
	}

	var body: some View {
		List {
			Section {
				HQText("Choose the default currency for your amounts. You can set a different currency on individual items when you edit them.")
					.font(.footnote)
					.foregroundStyle(.secondary)
			}

			if searchText.isEmpty {
				Section {
					CurrencyOptionRow(
						title: "Default",
						subtitle: "Follows your device — \(Currency.deviceDefault)",
						isSelected: viewModel.selectedCode == nil
					) {
						viewModel.select(nil)
					}
				}
			}

			Section {
				ForEach(filteredCodes, id: \.self) { code in
					CurrencyOptionRow(
						title: code,
						subtitle: Currency.localizedName(for: code),
						isSelected: viewModel.selectedCode == code
					) {
						viewModel.select(code)
					}
				}
			}
		}
		.searchable(text: $searchText)
		.navigationTitle("Currency")
		#if !os(macOS)
			.navigationBarTitleDisplayMode(.inline)
		#endif
		.task {
			await viewModel.load()
		}
	}
}

#Preview {
	NavigationStack {
		CurrencySettingsView()
	}
}
