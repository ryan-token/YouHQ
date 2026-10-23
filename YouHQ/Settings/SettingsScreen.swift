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
		case currency
		case onboarding
		#if DEBUG
			case sampleData
		#endif
	}

	@Environment(PaywallPresenter.self) private var paywallPresenter
	@Environment(\.dismiss) private var dismiss
	// Lives above the split view, so a chosen setting survives the split view collapsing and
	// expanding as an iPad window resizes or an iPhone Duo folds. On iOS it stays `nil` until the
	// user picks a row: a collapsed split view would push any preselection past the list.
	@State private var selectedSetting: SettingsOption?

	var body: some View {
		@Bindable var paywallPresenter = paywallPresenter

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

					SettingsNavLabel(
						labelText: "Currency",
						iconName: "coloncurrencysign.square.fill",
						iconColor: iconColor(for: .currency)
					)
					.tag(SettingsOption.currency)
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

				#if DEBUG
					Section("Developer") {
						SettingsNavLabel(
							labelText: "Sample Data",
							iconName: "shippingbox.circle.fill",
							iconColor: iconColor(for: .sampleData)
						)
						.tag(SettingsOption.sampleData)
					}
				#endif
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
					ToolbarItem(placement: .cancellationAction) {
						Button("Close", systemImage: "xmark") {
							dismiss()
						}
					}
				}
			#endif
		} detail: {
			Group {
				switch selectedSetting {
				// With nothing chosen, the detail column beside the list shows Premium; a collapsed
				// split view shows the list instead.
				case .premium, nil:
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
				case .currency:
					CurrencySettingsView()
				case .onboarding:
					AppOnboardingFlow(fromSettings: true)
				#if DEBUG
					case .sampleData:
						SampleDataSettingsView()
				#endif
				}
			}
			.frame(maxHeight: .infinity, alignment: .top)
		}
		#if os(macOS)
			.onAppear {
				selectedSetting = .premium
			}
		#else
			.horizontalToolbarForSingleActionSheet()
		#endif
		.onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
			dismiss()
		}
		#if os(macOS)
			.sheet(isPresented: $paywallPresenter.isShowingPaywallInSettingsWindow) {
				Paywall()
			}
		#else
			.onChange(of: paywallPresenter.needsSettingsDismissalBeforePaywall) {
				if paywallPresenter.needsSettingsDismissalBeforePaywall {
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
			case .currency:
				.mint
			case .onboarding:
				.orange
			#if DEBUG
				case .sampleData:
					.yellow
			#endif
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
		.environment(PaywallManager())
		.environment(PaywallPresenter())
}
