//
//  SettingsToolbarItem.swift
//  YouHQ
//
//  Created by Ryan Token on 1/25/26.
//

import SwiftUI

struct SettingsToolbarItem: ToolbarContent {
	var body: some ToolbarContent {
		ToolbarItem(placement: .navigation) {
			#if os(macOS)
				MacOSSettingsButton()
			#else
				SettingsButton()
			#endif
		}
	}

	#if os(macOS)
		private struct MacOSSettingsButton: View {
			@Environment(\.openWindow) private var openWindow

			var body: some View {
				Button {
					openWindow(id: "settings")
				} label: {
					Image(systemName: "gear")
				}
			}
		}
	#else
		private struct SettingsButton: View {
			@Environment(PaywallManager.self) private var paywallManager
			@State private var isShowingSettingsSheet = false

			var body: some View {
				Button {
					isShowingSettingsSheet = true
				} label: {
					Image(systemName: "gear")
				}
				.sheet(
					isPresented: $isShowingSettingsSheet,
					onDismiss: {
						if paywallManager.needsSettingsDismissalBeforePaywall {
							paywallManager.needsSettingsDismissalBeforePaywall = false
							paywallManager.showPaywall()
						}
					}
				) {
					SettingsScreen()
				}
			}
		}
	#endif
}

#Preview {
	HQText("Sample view with toolbar")
		.frame(width: 100, height: 74)
		.toolbar {
			SettingsToolbarItem()
		}
}
