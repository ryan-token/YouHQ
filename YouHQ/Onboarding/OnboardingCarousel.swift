//
//  OnboardingCarousel.swift
//  YouHQ
//
//  Created by Ryan Token on 5/20/26.
//

import SwiftUI

/// Auto-advancing image carousel that introduces the major sections of the app
/// before sending the user into profile creation.
struct OnboardingCarousel: View {
	@Environment(\.colorScheme) private var colorScheme
	#if !os(macOS)
		@Environment(\.horizontalSizeClass) private var horizontalSizeClass
		@Environment(\.verticalSizeClass) private var verticalSizeClass
	#endif
	@Bindable var vm: AppOnboardingFlow.ViewModel

	let timeOnEachTab: Int
	let lastAutoAdvanceTab: Int
	let onSummaryAdvance: () -> Void

	/// Regular in both dimensions, such as a full-screen iPad or iPhone Duo's inner display.
	/// Landscape iPhones stay compact here because their height is compact.
	private var usesRegularLayout: Bool {
		#if os(macOS)
			false
		#else
			horizontalSizeClass == .regular && verticalSizeClass == .regular
		#endif
	}

	var body: some View {
		// Both screenshot sets have the same slides, so the selected tab (owned by `vm`)
		// carries over when folding or resizing switches between them.
		let screenshots = OnboardingScreenshot.appOnboardingScreenshots(usesRegularLayout: usesRegularLayout)

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
			#if os(iOS)
				.padding(.top, usesRegularLayout ? 40 : 0)
			#endif

			TabView(selection: $vm.currentTab) {
				ForEach(0..<screenshots.count, id: \.self) { idx in
					Slide(screenshot: screenshots[idx], colorScheme: colorScheme)
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
		.task {
			await runAutoAdvanceTimer()
		}
	}

	/// Ticks once a second while auto-advance is active. Being a `task`, it stops when the
	/// carousel leaves the screen and resumes when it returns.
	private func runAutoAdvanceTimer() async {
		while vm.isTimerActive {
			do {
				try await Task.sleep(for: .seconds(1))
			} catch {
				return
			}
			vm.handleTimerTick(timeOnEachTab: timeOnEachTab, lastAutoAdvanceTab: lastAutoAdvanceTab)
		}
	}
}
