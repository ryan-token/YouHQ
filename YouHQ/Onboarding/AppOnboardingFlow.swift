//
//  AppOnboardingFlow.swift
//  YouHQ
//
//  Created by Ryan Token on 2/7/26.
//

import Combine
import SwiftUI

struct AppOnboardingFlow: View {
	@Environment(\.colorScheme) var colorScheme

	@State private var currentTab: Int = 0
	@State private var initialTimerCounter = 0
	@State private var mainTimerCounter = 0
	@State private var isTimerActive = true
	@State private var expectedTab: Int?
	@State private var isStartingOnboarding = true
	@State private var navigationPath = NavigationPath()

	let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	let totalTabs = 6
	let timeOnEachTab = 4

	var body: some View {
		NavigationStack(path: $navigationPath) {
			VStack {
				VStack(spacing: 0) {
					ScalableImage("AppIcon", height: 90)
					HQText("YouHQ")
						.font(.largeTitle)
						.fontWeight(.black)
				}
				.padding(.top)

				HQText("Your life, organized.")
					.font(.title)
					.fontWeight(.semibold)

				TabView(selection: $currentTab) {
					ForEach(0..<5) { idx in
						VStack {
							ScalableImage(
								colorScheme == .light ? screenshots[idx].imageNameLight : screenshots[idx].imageNameDark,
								height: nil
							)
							.frame(maxHeight: 525)

							HQText(screenshots[idx].title)
								.font(.title)
								.fontWeight(.black)

							HQText(screenshots[idx].description)
								.font(.headline)
								.fontWeight(.semibold)
						}
						.padding(.horizontal, 16)
						.padding(.bottom, 40)
						.tag(idx)
					}

					OnboardingEndView {
						navigationPath.append("congratulations")
					}
					.tag(5)
				}
				#if !os(macOS)
					.tabViewStyle(.page)
				#else
					.tabViewStyle(.grouped)
				#endif
				.opacity(isStartingOnboarding ? 0 : 1)
			}
			.navigationDestination(for: String.self) { destination in
				if destination == "congratulations" {
					OnboardingCongratulationsView()
				}
			}
			.onChange(of: currentTab) {
				// Check if this was a timer-driven change
				if expectedTab == currentTab {
					expectedTab = nil // Reset
				} else {
					// This was a manual swipe
					isTimerActive = false
				}
			}
			.onReceive(timer) { _ in
				guard isTimerActive else { return }

				if isStartingOnboarding {
					initialTimerCounter += 1

					if initialTimerCounter == 2 {
						withAnimation {
							isStartingOnboarding = false
						}
					}
				} else {
					mainTimerCounter += 1
					guard currentTab != totalTabs - 1 else { return }

					if mainTimerCounter % timeOnEachTab == 0 {
						let newTab = mainTimerCounter / timeOnEachTab
						expectedTab = newTab
						withAnimation {
							currentTab = newTab
						}
					}
				}
			}
		}
	}

	private let screenshots: [ScreenshotConfig] = [
		.init(
			title: "Home",
			description: "Track utilities, paint colors, maintenance items, and more.",
			imageNameLight: "onboarding.home.light",
			imageNameDark: "onboarding.home.dark"
		),
		.init(
			title: "Vehicles",
			description: "Track auto insurance, paint colors, and maintenance items.",
			imageNameLight: "onboarding.vehicles.light",
			imageNameDark: "onboarding.vehicles.dark"
		),
		.init(
			title: "Money",
			description: "Track bank accounts, investment accounts, HSA/FSAs, and insurance policies.",
			imageNameLight: "onboarding.money.light",
			imageNameDark: "onboarding.money.dark"
		),
		.init(
			title: "Media",
			description: "Track service providers, subscriptions, and devices.",
			imageNameLight: "onboarding.media.light",
			imageNameDark: "onboarding.media.dark"
		),
		.init(
			title: "Career",
			description: "Track jobs and salary history over time.",
			imageNameLight: "onboarding.career.light",
			imageNameDark: "onboarding.career.dark"
		)
	]

	private struct ScreenshotConfig {
		let title: String
		let description: String
		let imageNameLight: String
		let imageNameDark: String
	}
}

#Preview {
	AppOnboardingFlow()
}
