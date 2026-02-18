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
		@Dependency(\.defaultSyncEngine) var syncEngine
		@Bindable var vm: CareerScreen.ViewModel
		let namespace: Namespace.ID

		var body: some ToolbarContent {
			if vm.sortedJobs.isEmpty && syncEngine.isSynchronizing {
				ToolbarItem(placement: .primaryAction) {
					ProgressView()
				}
			} else {
				ToolbarItem(placement: .primaryAction) {
					Menu {
						CareerMenu(vm: vm)
					} label: {
						Label("Add", systemImage: "plus")
					}
					.matchedTransitionSource(id: "addButton", in: namespace)
				}
			}
		}
	}
}
