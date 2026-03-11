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
	@Environment(\.dismiss) private var dismiss
	@Environment(PaywallManager.self) private var paywallManager

	@State private var vm = ViewModel()

	let fromSettings: Bool
	let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	let timeOnEachTab = 4
	let lastAutoAdvanceTab = 5 // Stop auto-advancing after OnboardingSummaryView
	private let screenshots = makeScreenshots()

	init(fromSettings: Bool = false) {
		self.fromSettings = fromSettings
	}

	var body: some View {
		NavigationStack(path: $vm.navigationPath) {
			Group {
				switch vm.phase {
				case .tabView:
					tabViewPhase
				case .paywall:
					paywallPhase
				}
			}
			.navigationDestination(for: String.self) { destination in
				if destination == "congratulations" {
					OnboardingCongratulationsView()
				}
			}
		}
		#if !os(macOS)
			.toolbar(.hidden, for: .navigationBar)
			.overlay(alignment: .topLeading) {
				if fromSettings && UIDevice.current.userInterfaceIdiom == .phone {
					backButton
					.padding()
				}
			}
		#endif
		.task {
			await paywallManager.refreshEntitlementsIfNeeded()
		}
	}

	// MARK: - Tab View Phase

	private var tabViewPhase: some View {
		VStack(spacing: 8) {
			VStack(spacing: 0) {
				ScalableImage("AppIcon-1024", height: 90)

				HQText("YouHQ")
					.font(.largeTitle)
					.fontWeight(.black)

				HQText("Your life, organized.")
					.font(.title)
					.fontWeight(.semibold)
			}
			.padding(.top)
			#if !os(macOS)
				.if(UIDevice.current.userInterfaceIdiom == .pad) {
					$0.padding(.top, 40)
				}
			#endif

			TabView(selection: $vm.currentTab) {
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

				OnboardingSummaryView {
					withAnimation {
						vm.currentTab = 6
					}
				}
				.tag(5)

				OnboardingProfileCreationView {
					withAnimation {
						vm.currentTab = 7
					}
				}
				.tag(6)

				OnboardingReminderView {
					vm.navigateAfterProfileCreation(hasUnlockedPremium: paywallManager.hasUnlockedPremium)
				}
				.tag(7)
			}
			#if !os(macOS)
				.tabViewStyle(.page(indexDisplayMode: .never))
			#else
				.tabViewStyle(.grouped)
			#endif
			.opacity(vm.isStartingOnboarding ? 0 : 1)
		}
		.onChange(of: vm.currentTab) {
			vm.handleManualTabChange()
		}
		.onReceive(timer) { _ in
			vm.handleTimerTick(timeOnEachTab: timeOnEachTab, lastAutoAdvanceTab: lastAutoAdvanceTab)
		}
	}

	// MARK: - Paywall Phase

	@ViewBuilder
	private var paywallPhase: some View {
		#if os(macOS)
			ScrollView {
				Paywall(fromOnboarding: true, shouldShowSkipButton: true, shouldShowDismissButton: false) {
					vm.navigationPath.append("congratulations")
				}
			}
		#else
			Paywall(fromOnboarding: true, shouldShowSkipButton: true, shouldShowDismissButton: false) {
				vm.navigationPath.append("congratulations")
			}
			.background(PaywallGradient())
		#endif
	}

	private var backButton: some View {
		Button {
			dismiss()
		} label: {
			Image(systemName: "chevron.left")
				.font(.title2.weight(.medium))
		}
		#if !os(visionOS)
			.buttonStyle(.glass)
		#endif
	}

	private static var platform: String {
		#if os(iOS)
			switch UIDevice.current.userInterfaceIdiom {
			case .phone:
				"ios"
			case .pad:
				"ipados"
			default:
				"ios"
			}
		#elseif os(macOS)
			"macos"
		#elseif os(visionOS)
			"visionos"
		#else
			"ios"
		#endif
	}

	private static func makeScreenshots() -> [ScreenshotConfig] {
		#if os(visionOS)
			return [
				.init(
					title: "Home", description: "Track utilities, paint colors, maintenance, & more",
					imageNameLight: "\(platform).onboarding.home", imageNameDark: "\(platform).onboarding.home"),
				.init(
					title: "Vehicles", description: "Track insurance, paint colors, & maintenance",
					imageNameLight: "\(platform).onboarding.vehicles", imageNameDark: "\(platform).onboarding.vehicles"),
				.init(
					title: "Money", description: "Track banks, investment accounts, & HSA/FSAs",
					imageNameLight: "\(platform).onboarding.money", imageNameDark: "\(platform).onboarding.money"),
				.init(
					title: "Media", description: "Track service providers, subscriptions, & devices",
					imageNameLight: "\(platform).onboarding.media", imageNameDark: "\(platform).onboarding.media"),
				.init(
					title: "Career", description: "Track jobs & salary history over time", imageNameLight: "\(platform).onboarding.career",
					imageNameDark: "\(platform).onboarding.career")
			]
		#else
			return [
				.init(
					title: "Home", description: "Track utilities, paint colors, maintenance, & more",
					imageNameLight: "\(platform).onboarding.home.light", imageNameDark: "\(platform).onboarding.home.dark"),
				.init(
					title: "Vehicles", description: "Track insurance, paint colors, & maintenance",
					imageNameLight: "\(platform).onboarding.vehicles.light", imageNameDark: "\(platform).onboarding.vehicles.dark"),
				.init(
					title: "Money", description: "Track banks, investment accounts, & HSA/FSAs",
					imageNameLight: "\(platform).onboarding.money.light", imageNameDark: "\(platform).onboarding.money.dark"),
				.init(
					title: "Media", description: "Track service providers, subscriptions, & devices",
					imageNameLight: "\(platform).onboarding.media.light", imageNameDark: "\(platform).onboarding.media.dark"),
				.init(
					title: "Career", description: "Track jobs & salary history over time",
					imageNameLight: "\(platform).onboarding.career.light",
					imageNameDark: "\(platform).onboarding.career.dark")
			]
		#endif
	}

	private struct ScreenshotConfig {
		let title: String
		let description: String
		let imageNameLight: String
		let imageNameDark: String
	}
}

#Preview {
	struct AppOnboardingPreview: View {
		@State private var paywallManager = PaywallManager()

		var body: some View {
			NavigationStack {
				AppOnboardingFlow()
					.environment(paywallManager)
			}
		}
	}
	return AppOnboardingPreview()
}
