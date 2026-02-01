//
//  AppEntryPoint.swift
//  YouHQ
//
//  Created by Ryan Token on 12/29/25.
//

import SwiftUI

enum AppTab: String, Hashable {
	case home, vehicles, money, media, career
}

struct AppEntryPoint: View {
	@Environment(PaywallManager.self) private var paywallManager
	@State private var selectedTab: AppTab = .home

	var body: some View {
		@Bindable var paywallManager = paywallManager
		TabView(selection: $selectedTab) {
			Tab("Home", systemImage: "house", value: .home) {
				NavigationStack {
					ResidenceScreen()
						.toolbar {
							SettingsToolbarItem()
						}
						.sheet(isPresented: $paywallManager.isShowingPaywallSheet) {
							Paywall()
						}
				}
			}
			Tab("Vehicles", systemImage: "car.2", value: .vehicles) {
				NavigationStack {
					VehicleScreen()
						.toolbar {
							SettingsToolbarItem()
						}
						.sheet(isPresented: $paywallManager.isShowingPaywallSheet) {
							Paywall()
						}
				}
			}
			Tab("Money", systemImage: "dollarsign", value: .money) {
				NavigationStack {
					MoneyScreen()
						.toolbar {
							SettingsToolbarItem()
						}
						.sheet(isPresented: $paywallManager.isShowingPaywallSheet) {
							Paywall()
						}
				}
			}
			Tab("Media", systemImage: "desktopcomputer.and.macbook", value: .media) {
				NavigationStack {
					MediaScreen()
						.toolbar {
							SettingsToolbarItem()
						}
						.sheet(isPresented: $paywallManager.isShowingPaywallSheet) {
							Paywall()
						}
				}
			}
			Tab("Career", systemImage: "briefcase", value: .career) {
				NavigationStack {
					CareerScreen()
						.toolbar {
							SettingsToolbarItem()
						}
						.sheet(isPresented: $paywallManager.isShowingPaywallSheet) {
							Paywall()
						}
				}
			}
		}
		.onChange(of: selectedTab) {
			handleTabSelection(for: selectedTab)
		}
	}

	private func handleTabSelection(for tab: AppTab) {
		switch tab {
		case .home:
			Analytics.sendSignal(.residencesTabTapped)
		case .vehicles:
			Analytics.sendSignal(.vehiclesTabTapped)
		case .money:
			Analytics.sendSignal(.moneyTabTapped)
		case .media:
			Analytics.sendSignal(.mediaTabTapped)
		case .career:
			Analytics.sendSignal(.careerTabTapped)
		}
	}
}

#Preview {
	AppEntryPoint()
}
