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
		let vm: MediaScreen.ViewModel
		let namespace: Namespace.ID

		var body: some ToolbarContent {
			AddMenuToolbarItem(showProgressViewIfSyncing: vm.hasNoMediaItems, namespace: namespace) {
				MediaMenu(vm: vm)
			}
		}
	}
}
