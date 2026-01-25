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

		var body: some View {
			ContentUnavailableView {
				Label("No accounts", systemImage: "dollarsign.circle")
			} description: {
				Menu("Add Account") {
					MoneyMenu(vm: vm)
				}
			}
			.frame(maxWidth: .infinity, alignment: .center)
		}
	}
}
