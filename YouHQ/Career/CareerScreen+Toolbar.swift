//
//  CareerScreen+Toolbar.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

extension CareerScreen {
	struct Toolbar: ToolbarContent {
		@Bindable var vm: CareerScreen.ViewModel
		let namespace: Namespace.ID

		var body: some ToolbarContent {
			AddMenuToolbarItem(showProgressViewIfSyncing: vm.sortedJobs.isEmpty, namespace: namespace) {
				CareerMenu(vm: vm)
			}
		}
	}
}
