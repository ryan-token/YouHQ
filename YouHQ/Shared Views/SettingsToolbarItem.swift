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
				Button("Settings", systemImage: "gear", action: openSettings)
			}

			private func openSettings() {
				openWindow(id: "settings")
			}
		}
	#else
		private struct SettingsButton: View {
			@Environment(PaywallPresenter.self) private var paywallPresenter
			@State private var isShowingSettingsSheet = false

			var body: some View {
				Button("Settings", systemImage: "gear", action: showSettings)
					.sheet(isPresented: $isShowingSettingsSheet, onDismiss: settingsDismissed) {
						SettingsScreen()
					}
			}

			private func showSettings() {
				isShowingSettingsSheet = true
			}

			/// Settings asks to be dismissed before the paywall appears, so the paywall can
			/// present from `AppTabView` instead of stacking on top of the Settings sheet.
			private func settingsDismissed() {
				if paywallPresenter.needsSettingsDismissalBeforePaywall {
					paywallPresenter.needsSettingsDismissalBeforePaywall = false
					paywallPresenter.showPaywall()
				}
			}
		}
	#endif
}

#Preview {
	NavigationStack {
		HQText("Sample view with toolbar")
			.toolbar {
				SettingsToolbarItem()
			}
	}
	.environment(PaywallManager())
	.environment(PaywallPresenter())
}
