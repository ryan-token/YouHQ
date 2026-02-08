//
//  SettingsToolbarItem.swift
//  YouHQ
//
//  Created by Ryan Token on 1/25/26.
//

import SwiftUI

struct SettingsToolbarItem: ToolbarContent {
	#if os(macOS)
		@Environment(\.openWindow) private var openWindow
	#else
		@State private var isShowingSettingsSheet = false
	#endif

	var body: some ToolbarContent {
		ToolbarItem(placement: .navigation) {
			Button {
				#if os(macOS)
					openWindow(id: "settings")
				#else
					isShowingSettingsSheet = true
				#endif
			} label: {
				Image(systemName: "gear")
			}
			#if !os(macOS)
				.sheet(isPresented: $isShowingSettingsSheet) {
					SettingsScreen()
				}
			#endif
		}
	}
}

#Preview {
	HQText("Sample view with toolbar")
		.frame(width: 100, height: 74)
		.toolbar {
			SettingsToolbarItem()
		}
}
