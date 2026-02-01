//
//  SettingsScreen.swift
//  YouHQ
//
//  Created by Ryan Token on 1/25/26.
//

import SwiftUI

struct SettingsScreen: View {
	enum SettingsOption {
		case premium
		case profiles
	}

	@Environment(\.dismiss) var dismiss
	@State private var selectedSetting: SettingsOption?

	var body: some View {
		NavigationSplitView {
			List(selection: $selectedSetting) {
				Section("Preferences") {
					SettingsNavLabel(
						labelText: "YouHQ Premium",
						iconName: "star.square.fill",
						iconColor: .purple
					)
					.tag(SettingsOption.premium)

					SettingsNavLabel(
						labelText: "Profiles",
						iconName: "person.2.square.stack.fill",
						iconColor: .blue
					)
					.tag(SettingsOption.profiles)
				}

				Section("More") {
					RateAppButton()
					TermsAndPrivacyPolicyButton()
				}
			}
			.listStyle(.sidebar)
			.navigationTitle("Settings")
			#if os(macOS)
				.navigationSplitViewColumnWidth(210)
			#else
				.navigationSplitViewColumnWidth(300)
			#endif

			#if !os(macOS)
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .navigation) {
						Button {
							dismiss()
						} label: {
							Image(systemName: "xmark")
						}
					}
				}
			#endif
		} detail: {
			Group {
				switch selectedSetting {
				case .premium:
					#if os(macOS)
						ScrollView {
							Paywall(fromSettings: true)
						}
					#else
						Paywall(fromSettings: true)
					#endif
				case .profiles:
					ProfileSettingsView()
				case nil:
					ContentUnavailableView {
						Label("No Selection", systemImage: "questionmark.circle")
					} description: {
						Text("Tap an option in the sidebar for settings.")
					}
				}
			}
			.frame(maxHeight: .infinity, alignment: .top)
		}
	}
}

#Preview {
	SettingsScreen()
}
