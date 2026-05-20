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
		case notifications
		case onboarding
	}

	@Environment(PaywallManager.self) private var paywallManager
	@Environment(\.dismiss) var dismiss
	@State private var selectedSetting: SettingsOption?

	var body: some View {
		@Bindable var paywallManager = paywallManager

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

					SettingsNavLabel(
						labelText: "Notifications",
						iconName: "bell.square.fill",
						iconColor: iconColor(for: .notifications)
					)
					.tag(SettingsOption.notifications)
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
						Button("Close", systemImage: "xmark") {
							dismiss()
						}
						.labelStyle(.iconOnly)
					}
				}
			#endif
		} detail: {
			Group {
				switch selectedSetting {
				case .premium:
					#if os(macOS)
						ScrollView {
							Paywall(shouldShowDismissButton: false)
						}
					#else
						Paywall(shouldShowDismissButton: false)
					#endif
				case .profiles:
					ProfileSettingsView()
				case .notifications:
					NotificationSettingsView()
				case .onboarding:
					AppOnboardingFlow(fromSettings: true)
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
		#if os(macOS)
		.sheet(isPresented: $paywallManager.isShowingPaywallInSettingsWindow) {
			Paywall()
		}
		#else
		.onChange(of: paywallManager.needsSettingsDismissalBeforePaywall) {
			if paywallManager.needsSettingsDismissalBeforePaywall {
				dismiss()
			}
		}
		#endif
	}

	private func iconColor(for setting: SettingsOption) -> Color {
		var settingColor: Color {
			switch setting {
			case .premium:
				.indigo
			case .profiles:
				.blue
			case .notifications:
				.green
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
