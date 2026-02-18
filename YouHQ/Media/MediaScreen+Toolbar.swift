//
//  MediaScreen+Toolbar.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

extension MediaScreen {
	struct Toolbar: ToolbarContent {
		@Dependency(\.defaultSyncEngine) var syncEngine
		@Bindable var vm: MediaScreen.ViewModel
		let namespace: Namespace.ID

		var body: some ToolbarContent {
			if vm.deviceViewModel.devices.isEmpty
				&& vm.serviceProviderViewModel.serviceProviders.isEmpty
				&& vm.subscriptionViewModel.subscriptions.isEmpty
				&& vm.otherViewModel.others.isEmpty
				&& syncEngine.isSynchronizing
			{
				ToolbarItem(placement: .primaryAction) {
					ProgressView()
				}
			} else {
				ToolbarItem(placement: .primaryAction) {
					Menu {
						MediaMenu(vm: vm)
					} label: {
						Label("Add", systemImage: "plus")
					}
					.matchedTransitionSource(id: "addButton", in: namespace)
				}
			}
		}
	}
}
