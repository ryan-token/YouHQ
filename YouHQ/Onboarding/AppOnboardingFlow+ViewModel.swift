//
//  AppOnboardingFlow+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 2/11/26.
//

import SwiftUI

extension AppOnboardingFlow {
	enum Destination: Hashable {
		case profileCreation
		case reminder
		case paywall
		case congratulations
	}

	@Observable
	@MainActor
	class ViewModel {
		var currentTab: Int = 0
		var isStartingOnboarding = true
		var navigationPath: [Destination] = []
		var isTimerActive = true
		var initialTimerCounter = 0
		var mainTimerCounter = 0

		private var expectedTab: Int?

		/// Stops auto-advancing the tab timer when the user manually swipes.
		func handleManualTabChange() {
			if expectedTab == currentTab {
				expectedTab = nil
			} else {
				isTimerActive = false
			}
		}

		func handleTimerTick(timeOnEachTab: Int, lastAutoAdvanceTab: Int) {
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

		func navigateAfterReminder(hasUnlockedPremium: Bool) {
			if hasUnlockedPremium {
				navigationPath.append(.congratulations)
			} else {
				navigationPath.append(.paywall)
			}
		}
	}
}
