//
//  AddMenuToolbarItem.swift
//  YouHQ
//
//  Created by Ryan Token on 5/20/26.
//

import SQLiteData
import SwiftUI

/// The `+` toolbar item used on every tab's primary screen.
///
/// Shows a `ProgressView` while the screen's collections are empty and the sync engine is still
/// synchronizing the initial pull; otherwise shows the `Add` menu with a matched transition source
/// so the presented sheet zooms from the button.
struct AddMenuToolbarItem<MenuContent: View>: ToolbarContent {
	@Dependency(\.defaultSyncEngine) var syncEngine

	let showProgressViewIfSyncing: Bool
	let namespace: Namespace.ID
	@ViewBuilder let menu: () -> MenuContent

	var body: some ToolbarContent {
		if showProgressViewIfSyncing && syncEngine.isSynchronizing {
			ToolbarItem(placement: .primaryAction) {
				ProgressView()
			}
		} else {
			ToolbarItem(placement: .primaryAction) {
				Menu {
					menu()
				} label: {
					Label("Add", systemImage: "plus")
				}
				.matchedTransitionSource(id: "addButton", in: namespace)
			}
		}
	}
}
