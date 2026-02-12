//
//  AppOnboardingFlow+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 2/11/26.
//

import Combine
import SQLiteData
import SwiftUI

extension AppOnboardingFlow {
	@Observable
	@MainActor
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) private var database

		var currentTab: Int = 0
		var isStartingOnboarding = true
		var navigationPath = NavigationPath()
		var showProfileRequiredAlert = false
		var hasAnyProfile = false

		private(set) var initialTimerCounter = 0
		private(set) var mainTimerCounter = 0
		private(set) var isTimerActive = true
		private(set) var expectedTab: Int?

		let paywallTab = 7

		func checkForProfile() async {
			do {
				let profileCount = try await database.read { db in
					try Profile.fetchCount(db)
				}
				hasAnyProfile = profileCount > 0
			} catch {
				print("Error checking for profiles: \(error)")
				hasAnyProfile = false
			}
		}

		func handleTabChange(oldValue: Int, newValue: Int, hasUnlockedPremium: Bool) async {
			// Handle swiping forward from profile creation screen
			if oldValue == 6 && newValue == paywallTab {
				await checkForProfile()

				// If no profile exists, block the swipe
				if !hasAnyProfile {
					withAnimation(.smooth) {
						currentTab = 6
					}
					showProfileRequiredAlert = true
					return
				}

				// If user has premium, skip paywall and go to congratulations
				if hasUnlockedPremium {
					navigationPath.append("congratulations")
					return
				}
			}

			// Check if this was a timer-driven change
			if expectedTab == currentTab {
				expectedTab = nil
			} else {
				// This was a manual swipe
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

		func navigateAfterProfileCreation(hasUnlockedPremium: Bool) {
			// Skip paywall if user already has premium
			if hasUnlockedPremium {
				navigationPath.append("congratulations")
			} else {
				currentTab = paywallTab
			}
		}
	}
}
