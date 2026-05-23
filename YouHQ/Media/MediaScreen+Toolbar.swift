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
		@Bindable var vm: MediaScreen.ViewModel
		let namespace: Namespace.ID

		private var hasNoMediaItems: Bool {
			vm.deviceViewModel.devices.isEmpty
				&& vm.serviceProviderViewModel.serviceProviders.isEmpty
				&& vm.subscriptionViewModel.subscriptions.isEmpty
				&& vm.otherViewModel.others.isEmpty
		}

		var body: some ToolbarContent {
			AddMenuToolbarItem(showProgressViewIfSyncing: hasNoMediaItems, namespace: namespace) {
				MediaMenu(vm: vm)
			}
		}
	}
}
