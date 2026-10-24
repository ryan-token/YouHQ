//
//  AddMenuToolbarItemContent.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import SwiftUI

/// The single toolbar item behind `AddMenuToolbarItem`: a `ProgressView` during the initial
/// sync, otherwise the `Add` menu acting as the matched transition source for its sheet.
struct AddMenuToolbarItemContent<MenuContent: View>: ToolbarContent {
	let isShowingProgress: Bool
	let namespace: Namespace.ID
	let menu: MenuContent

	var body: some ToolbarContent {
		ToolbarItem(placement: .primaryAction) {
			if isShowingProgress {
				ProgressView()
			} else {
				Menu("Add", systemImage: "plus") {
					menu
				}
				.matchedTransitionSource(id: "addButton", in: namespace)
			}
		}
	}
}
