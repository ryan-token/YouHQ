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

	var body: some View {
		CurrencyList(
			selectedCode: viewModel.selectedCode,
			defaultSubtitle: "Follows your device — \(Currency.deviceDefault)",
			onSelect: { viewModel.select($0) }
		) {
			Section {
				HQText(
					"Choose the default currency for your amounts. You can set a different currency on individual items when you edit them."
				)
				.font(.footnote)
				.foregroundStyle(.secondary)
			}
		}
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
