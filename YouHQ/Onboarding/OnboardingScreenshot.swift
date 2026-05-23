//
//  OnboardingScreenshot.swift
//  YouHQ
//
//  Created by Ryan Token on 5/20/26.
//

import Foundation

#if canImport(UIKit)
	import UIKit
#endif

/// One slide's worth of metadata for the onboarding carousel.
struct OnboardingScreenshot {
	let title: String
	let description: String
	let imageNameLight: String
	let imageNameDark: String
}

extension OnboardingScreenshot {
	static let appOnboardingScreenshots: [OnboardingScreenshot] = makeScreenshots()

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

	private static func makeScreenshots() -> [OnboardingScreenshot] {
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
