//
//  MoneyScreen+Toolbar.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

extension MoneyScreen {
	struct Toolbar: ToolbarContent {
		let vm: MoneyScreen.ViewModel
		let namespace: Namespace.ID

		var body: some ToolbarContent {
			AddMenuToolbarItem(showProgressViewIfSyncing: vm.hasNoMoneyItems, namespace: namespace) {
				MoneyMenu(vm: vm)
			}
		}
	}
}
