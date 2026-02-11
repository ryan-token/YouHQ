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
	let timeOnEachTab = 4
	let lastAutoAdvanceTab = 5 // Stop auto-advancing after OnboardingEndView

	var body: some View {
		NavigationStack(path: $navigationPath) {
			VStack(spacing: 8) {
				VStack(spacing: 0) {
					ScalableImage("AppIcon", height: 90)

					HQText("YouHQ")
						.font(.largeTitle)
						.fontWeight(.black)

					HQText("Your life, organized.")
						.font(.title)
						.fontWeight(.semibold)
				}
				.padding(.top)

				TabView(selection: $currentTab) {
					ForEach(0..<5) { idx in
						VStack {
							ScalableImage(
								colorScheme == .light ? screenshots[idx].imageNameLight : screenshots[idx].imageNameDark,
								height: nil
							)
							.frame(maxHeight: 525)

							HQText(screenshots[idx].title)
								.font(.title2)
								.fontWeight(.bold)

							HQText(screenshots[idx].description)
								.font(.headline)
								.fontWeight(.medium)
						}
						.padding(.horizontal, 8)
						.padding(.bottom, 40)
						.tag(idx)
					}

					OnboardingEndView {
						withAnimation {
							currentTab = 6
						}
					}
					.tag(5)

					OnboardingProfileCreationView {
						navigationPath.append("congratulations")
					}
					.tag(6)
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

					if initialTimerCounter == 1 {
						withAnimation(.linear(duration: 2)) {
							isStartingOnboarding = false
						}
					}
				} else {
					mainTimerCounter += 1
					// Stop auto-advancing after lastAutoAdvanceTab
					guard currentTab < lastAutoAdvanceTab else { return }

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
		.toolbar(removing: .title)
	}

	private let screenshots: [ScreenshotConfig] = [
		.init(
			title: "Home",
			description: "Track utilities, paint colors, maintenance, & more",
			imageNameLight: "onboarding.home.light",
			imageNameDark: "onboarding.home.dark"
		),
		.init(
			title: "Vehicles",
			description: "Track insurance, paint colors, & maintenance",
			imageNameLight: "onboarding.vehicles.light",
			imageNameDark: "onboarding.vehicles.dark"
		),
		.init(
			title: "Money",
			description: "Track banks, investment accounts, & HSA/FSAs",
			imageNameLight: "onboarding.money.light",
			imageNameDark: "onboarding.money.dark"
		),
		.init(
			title: "Media",
			description: "Track service providers, subscriptions, & devices",
			imageNameLight: "onboarding.media.light",
			imageNameDark: "onboarding.media.dark"
		),
		.init(
			title: "Career",
			description: "Track jobs & salary history over time",
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
