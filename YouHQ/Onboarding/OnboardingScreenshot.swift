//
//  OnboardingScreenshot.swift
//  YouHQ
//
//  Created by Ryan Token on 5/20/26.
//

import Foundation

/// One slide's worth of metadata for the onboarding carousel.
struct OnboardingScreenshot {
	let title: String
	let description: String
	let imageNameLight: String
	let imageNameDark: String
}

extension OnboardingScreenshot {
	/// The carousel's slides, using the screenshot set that suits the space available.
	///
	/// On iOS this follows the window's size classes rather than the device idiom: the
	/// near-square iPad screenshots suit any window that is regular in both dimensions,
	/// including iPhone Duo's inner display (which reports a phone idiom), while the tall
	/// iPhone screenshots suit compact windows, including a narrow iPad split.
	static func appOnboardingScreenshots(usesRegularLayout: Bool) -> [OnboardingScreenshot] {
		#if os(iOS)
			usesRegularLayout ? regularLayoutScreenshots : compactLayoutScreenshots
		#else
			platformScreenshots
		#endif
	}

	#if os(iOS)
		private static let compactLayoutScreenshots = makeScreenshots(platform: "ios")
		private static let regularLayoutScreenshots = makeScreenshots(platform: "ipados")
	#elseif os(macOS)
		private static let platformScreenshots = makeScreenshots(platform: "macos")
	#elseif os(visionOS)
		private static let platformScreenshots = makeScreenshots(platform: "visionos")
	#else
		private static let platformScreenshots = makeScreenshots(platform: "ios")
	#endif

	private static func makeScreenshots(platform: String) -> [OnboardingScreenshot] {
		#if os(visionOS)
			return [
				OnboardingScreenshot(
					title: "Home",
					description: "Track utilities, paint colors, maintenance, & more",
					imageNameLight: "\(platform).onboarding.home",
					imageNameDark: "\(platform).onboarding.home"
				),
				OnboardingScreenshot(
					title: "Vehicles",
					description: "Track insurance, paint colors, & maintenance",
					imageNameLight: "\(platform).onboarding.vehicles",
					imageNameDark: "\(platform).onboarding.vehicles"
				),
				OnboardingScreenshot(
					title: "Money",
					description: "Track banks, investment accounts, & HSA/FSAs",
					imageNameLight: "\(platform).onboarding.money",
					imageNameDark: "\(platform).onboarding.money"
				),
				OnboardingScreenshot(
					title: "Media",
					description: "Track service providers, subscriptions, & devices",
					imageNameLight: "\(platform).onboarding.media",
					imageNameDark: "\(platform).onboarding.media"
				),
				OnboardingScreenshot(
					title: "Career",
					description: "Track jobs & salary history over time",
					imageNameLight: "\(platform).onboarding.career",
					imageNameDark: "\(platform).onboarding.career"
				)
			]
		#else
			return [
				OnboardingScreenshot(
					title: "Home",
					description: "Track utilities, paint colors, maintenance, & more",
					imageNameLight: "\(platform).onboarding.home.light",
					imageNameDark: "\(platform).onboarding.home.dark"
				),
				OnboardingScreenshot(
					title: "Vehicles",
					description: "Track insurance, paint colors, & maintenance",
					imageNameLight: "\(platform).onboarding.vehicles.light",
					imageNameDark: "\(platform).onboarding.vehicles.dark"
				),
				OnboardingScreenshot(
					title: "Money",
					description: "Track banks, investment accounts, & HSA/FSAs",
					imageNameLight: "\(platform).onboarding.money.light",
					imageNameDark: "\(platform).onboarding.money.dark"
				),
				OnboardingScreenshot(
					title: "Media",
					description: "Track service providers, subscriptions, & devices",
					imageNameLight: "\(platform).onboarding.media.light",
					imageNameDark: "\(platform).onboarding.media.dark"
				),
				OnboardingScreenshot(
					title: "Career",
					description: "Track jobs & salary history over time",
					imageNameLight: "\(platform).onboarding.career.light",
					imageNameDark: "\(platform).onboarding.career.dark"
				)
			]
		#endif
	}
}
