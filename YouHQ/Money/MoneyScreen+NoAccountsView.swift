//
//  MoneyScreen+NoAccountsView.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

extension MoneyScreen {
	struct NoAccountsView: View {
		let vm: ViewModel

		@Environment(\.sheetNamespace) private var namespace

		var body: some View {
			ContentUnavailableView {
				Label("No accounts", systemImage: "dollarsign.circle")
			} description: {
				Menu("Add Account") {
					MoneyMenu(vm: vm, sourceID: "emptyStateButton")
				}
				.matchedTransitionSource(id: "emptyStateButton", in: namespace)
			}
			.frame(maxWidth: .infinity, alignment: .center)
		}
	}
}
