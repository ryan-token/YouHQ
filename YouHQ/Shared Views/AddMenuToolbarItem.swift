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
	@ViewBuilder let menu: MenuContent

	var body: some ToolbarContent {
		// Adding is each tab's most frequent action, so keep it in the bar when space runs out —
		// on iPhone Duo's outer display the tabs, toolbar items and status share one vertical bar.
		// visionOS has no `.high` priority; its ornaments don't share space with tabs.
		#if os(visionOS)
			item
		#else
			if #available(iOS 27.0, macOS 26.1, *) {
				item.visibilityPriority(.high)
			} else {
				item
			}
		#endif
	}

	private var item: AddMenuToolbarItemContent<MenuContent> {
		AddMenuToolbarItemContent(
			isShowingProgress: showProgressViewIfSyncing && syncEngine.isSynchronizing,
			namespace: namespace,
			menu: menu
		)
	}
}
