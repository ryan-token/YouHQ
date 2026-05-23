//
//  OnboardingCarousel.swift
//  YouHQ
//
//  Created by Ryan Token on 5/20/26.
//

import Combine
import SwiftUI

/// Auto-advancing image carousel that introduces the major sections of the app
/// before sending the user into profile creation.
struct OnboardingCarousel: View {
	@Environment(\.colorScheme) private var colorScheme
	@Bindable var vm: AppOnboardingFlow.ViewModel

	let screenshots: [OnboardingScreenshot]
	let timeOnEachTab: Int
	let lastAutoAdvanceTab: Int
	let onSummaryAdvance: () -> Void

	private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

	var body: some View {
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
				.padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 0)
			#endif

			TabView(selection: $vm.currentTab) {
				ForEach(0..<screenshots.count, id: \.self) { idx in
					OnboardingCarouselSlide(screenshot: screenshots[idx], colorScheme: colorScheme)
						.tag(idx)
				}

				OnboardingSummaryView(onContinue: onSummaryAdvance)
					.tag(screenshots.count)
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
}

private struct OnboardingCarouselSlide: View {
	let screenshot: OnboardingScreenshot
	let colorScheme: ColorScheme

	var body: some View {
		VStack {
			ScalableImage(
				colorScheme == .light ? screenshot.imageNameLight : screenshot.imageNameDark,
				height: nil
			)
			.frame(maxHeight: 525)

			HQText(screenshot.title)
				.font(.title2)
				.fontWeight(.bold)

			HQText(screenshot.description)
				.font(.headline)
				.fontWeight(.medium)
		}
		.padding(.horizontal, 8)
		.padding(.bottom, 40)
	}
}
