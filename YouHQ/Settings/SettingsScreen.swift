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
		case onboarding
	}

	@Environment(\.dismiss) var dismiss
	@State private var selectedSetting: SettingsOption?

	var body: some View {
		NavigationSplitView {
			List(selection: $selectedSetting) {
				Section("Preferences") {
					SettingsNavLabel(
						labelText: "YouHQ Premium",
						iconName: "sparkle",
						iconColor: iconColor(for: .premium)
					)
					.tag(SettingsOption.premium)

					SettingsNavLabel(
						labelText: "Profiles",
						iconName: "person.2.square.stack.fill",
						iconColor: iconColor(for: .profiles)
					)
					.tag(SettingsOption.profiles)
				}

				Section("More") {
					SettingsNavLabel(
						labelText: "Onboarding",
						iconName: "point.bottomleft.forward.to.arrow.triangle.scurvepath",
						iconColor: iconColor(for: .onboarding)
					)
					.tag(SettingsOption.onboarding)

					RateAppButton()

					TermsAndPrivacyPolicyButton()
				}
			}
			.listStyle(.sidebar)
			.navigationTitle("Settings")
			#if os(macOS)
				.navigationSplitViewColumnWidth(250)
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
							Paywall()
						}
					#else
						Paywall()
					#endif
				case .profiles:
					ProfileSettingsView()
				case .onboarding:
					AppOnboardingFlow()
				case nil:
					ContentUnavailableView {
						Label("No Selection", systemImage: "questionmark.circle")
					} description: {
						HQText("Tap an option in the sidebar for settings.")
					}
				}
			}
			.frame(maxHeight: .infinity, alignment: .top)
		}
		.onAppear {
			#if !os(macOS)
				if UIDevice.current.userInterfaceIdiom != .phone {
					selectedSetting = .premium
				}
			#else
				selectedSetting = .premium
			#endif
		}
		.onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
			dismiss()
		}
	}

	private func iconColor(for setting: SettingsOption) -> Color {
		var settingColor: Color {
			switch setting {
			case .premium:
				.indigo
			case .profiles:
				.blue
			case .onboarding:
				.orange
			}
		}

		#if os(macOS)
			return selectedSetting == setting ? .white : settingColor
		#else
			return settingColor
		#endif
	}
}

#Preview {
	SettingsScreen()
}
