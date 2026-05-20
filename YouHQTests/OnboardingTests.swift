//
//  OnboardingTests.swift
//  YouHQTests
//
//  Created by Ryan Token on 2/21/26.
//

import Dependencies
import DependenciesTestSupport
import Foundation
import SQLiteData
import SwiftUI
import Testing

@testable import YouHQ

extension YouHQTests {
	@Suite("Onboarding")
	struct OnboardingTests {

		@Suite("Onboarding flow")
		struct OnboardingFlow {
			@Dependency(\.defaultDatabase) var database

			@Test("Initial state has correct defaults")
			func initialState() {
				let vm = AppOnboardingFlow.ViewModel()

				#expect(vm.currentTab == 0)
				#expect(vm.isStartingOnboarding == true)
				#expect(vm.isTimerActive == true)
			}

			@Test("navigateAfterReminder pushes paywall for free users")
			func navigateToPaywall() {
				let vm = AppOnboardingFlow.ViewModel()
				vm.navigateAfterReminder(hasUnlockedPremium: false)

				#expect(vm.navigationPath.last == .paywall)
			}

			@Test("navigateAfterReminder pushes congratulations for premium users")
			func navigateToCongratulations() {
				let vm = AppOnboardingFlow.ViewModel()
				vm.navigateAfterReminder(hasUnlockedPremium: true)

				#expect(vm.navigationPath.last == .congratulations)
			}

			@Test("Manual swipe disables timer")
			func manualSwipeDisablesTimer() async {
				let vm = AppOnboardingFlow.ViewModel()

				// Simulate a manual tab change (no expected tab set)
				vm.currentTab = 2
				vm.handleManualTabChange()

				#expect(vm.isTimerActive == false)
			}

			@Test("Timer tick transitions from starting to main onboarding")
			func timerTransition() {
				let vm = AppOnboardingFlow.ViewModel()

				#expect(vm.isStartingOnboarding == true)
				#expect(vm.initialTimerCounter == 0)

				vm.handleTimerTick(timeOnEachTab: 3, lastAutoAdvanceTab: 5)

				#expect(vm.initialTimerCounter == 1)
				// After first tick, isStartingOnboarding transitions (with animation)
			}

			@Test("Timer auto-advances tabs")
			func timerAutoAdvances() {
				let vm = AppOnboardingFlow.ViewModel()
				vm.isStartingOnboarding = false // skip initial phase

				// Tick 3 times with timeOnEachTab=3
				vm.handleTimerTick(timeOnEachTab: 3, lastAutoAdvanceTab: 5)
				vm.handleTimerTick(timeOnEachTab: 3, lastAutoAdvanceTab: 5)
				vm.handleTimerTick(timeOnEachTab: 3, lastAutoAdvanceTab: 5)

				#expect(vm.mainTimerCounter == 3)
				#expect(vm.currentTab == 1) // 3/3 = tab 1
			}
		}

		// MARK: - OnboardingProfileCreationView.ViewModel Tests

		@Suite("Profile creation")
		struct ProfileCreation {
			@Dependency(\.defaultDatabase) var database

			@Test("checkForProfile detects existing profile")
			func checkForProfile() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Existing", createdAt: Date(), updatedAt: Date())
					}
				}

				let vm = OnboardingProfileCreationView.ViewModel()
				await vm.checkForProfile()

				#expect(vm.hasAnyProfile == true)
				#expect(vm.existingProfileName == "Existing")
			}

			@Test("checkForProfile handles empty database")
			func checkForNoProfile() async {
				let vm = OnboardingProfileCreationView.ViewModel()
				await vm.checkForProfile()

				#expect(vm.hasAnyProfile == false)
				#expect(vm.existingProfileName == "")
			}

			@Test("loadItemCounts returns zero when no profile selected")
			func loadCountsNoProfile() async {
				let vm = OnboardingProfileCreationView.ViewModel()
				vm.selectedProfileIDString = ""
				await vm.loadItemCounts()

				#expect(vm.residencesCount == 0)
				#expect(vm.vehiclesCount == 0)
				#expect(vm.jobsCount == 0)
			}

			@Test("loadItemCounts returns correct counts for selected profile")
			func loadCountsWithData() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						Residence.Draft(id: UUID(-3), profileID: UUID(-1), street: "456 Oak")
						Vehicle.Draft(id: UUID(-4), profileID: UUID(-1), make: "Toyota")
						Job.Draft(id: UUID(-5), profileID: UUID(-1), company: "Acme")
						Job.Draft(id: UUID(-6), profileID: UUID(-1), company: "BigCo")
						Job.Draft(id: UUID(-7), profileID: UUID(-1), company: "MegaCorp")
					}
				}

				let vm = OnboardingProfileCreationView.ViewModel()
				vm.selectedProfileIDString = UUID(-1).uuidString
				await vm.loadItemCounts()

				#expect(vm.residencesCount == 2)
				#expect(vm.vehiclesCount == 1)
				#expect(vm.jobsCount == 3)
			}

			@Test("checkIfJobWasSaved finds existing job")
			func checkJobSaved() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Job.Draft(id: UUID(-2), profileID: UUID(-1), company: "Acme")
					}
				}

				let vm = OnboardingProfileCreationView.ViewModel()
				let result = await vm.checkIfJobWasSaved(jobID: UUID(-2))
				#expect(result == true)
			}

			@Test("checkIfJobWasSaved returns false for missing job")
			func checkJobNotSaved() async {
				let vm = OnboardingProfileCreationView.ViewModel()
				let result = await vm.checkIfJobWasSaved(jobID: UUID(-99))
				#expect(result == false)
			}
		}
	}
}
