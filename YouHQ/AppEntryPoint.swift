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
	@State private var selectedTab: AppTab = .home

	var body: some View {
		TabView(selection: $selectedTab) {
			Tab("Home", systemImage: "house", value: .home) {
				NavigationStack {
					ResidenceScreen()
				}
			}
			Tab("Vehicles", systemImage: "car.2", value: .vehicles) {
				NavigationStack {
					VehicleScreen()
				}
			}
			Tab("Money", systemImage: "dollarsign", value: .money) {
				NavigationStack {
					MoneyScreen()
				}
			}
			Tab("Media", systemImage: "desktopcomputer.and.macbook", value: .media) {
				NavigationStack {
					MediaScreen()
				}
			}
			Tab("Career", systemImage: "briefcase", value: .career) {
				NavigationStack {
					CareerScreen()
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
