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
				#expect(vm.showProfileRequiredAlert == false)
				#expect(vm.hasAnyProfile == false)
				#expect(vm.isTimerActive == true)
				#expect(vm.paywallTab == 7)
			}

			@Test("checkForProfile detects existing profiles")
			func checkForProfile() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					}
				}

				let vm = AppOnboardingFlow.ViewModel()
				await vm.checkForProfile()

				#expect(vm.hasAnyProfile == true)
			}

			@Test("checkForProfile detects no profiles")
			func checkForNoProfile() async {
				let vm = AppOnboardingFlow.ViewModel()
				await vm.checkForProfile()

				#expect(vm.hasAnyProfile == false)
			}

			@Test("handleTabChange blocks paywall when no profile exists")
			func blockPaywallWithoutProfile() async {
				let vm = AppOnboardingFlow.ViewModel()
				// No profiles in database
				vm.currentTab = 7 // paywall tab
				await vm.handleTabChange(oldValue: 6, newValue: 7, hasUnlockedPremium: false)

				#expect(vm.currentTab == 6)
				#expect(vm.showProfileRequiredAlert == true)
			}

			@Test("handleTabChange allows paywall when profile exists")
			func allowPaywallWithProfile() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					}
				}

				let vm = AppOnboardingFlow.ViewModel()
				vm.currentTab = 7
				await vm.handleTabChange(oldValue: 6, newValue: 7, hasUnlockedPremium: false)

				// Should stay on paywall tab
				#expect(vm.currentTab == 7)
				#expect(vm.showProfileRequiredAlert == false)
			}

			@Test("handleTabChange skips paywall for premium users")
			func skipPaywallForPremium() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					}
				}

				let vm = AppOnboardingFlow.ViewModel()
				vm.currentTab = 7
				await vm.handleTabChange(oldValue: 6, newValue: 7, hasUnlockedPremium: true)

				// Should have navigated to congratulations
				#expect(vm.navigationPath.count == 1)
			}

			@Test("navigateAfterProfileCreation goes to paywall for free users")
			func navigateToPaywall() {
				let vm = AppOnboardingFlow.ViewModel()
				vm.navigateAfterProfileCreation(hasUnlockedPremium: false)

				#expect(vm.currentTab == 7)
			}

			@Test("navigateAfterProfileCreation goes to congratulations for premium users")
			func navigateToCongratulations() {
				let vm = AppOnboardingFlow.ViewModel()
				vm.navigateAfterProfileCreation(hasUnlockedPremium: true)

				#expect(vm.navigationPath.count == 1)
			}

			@Test("Manual swipe disables timer")
			func manualSwipeDisablesTimer() async {
				let vm = AppOnboardingFlow.ViewModel()

				// Simulate a manual tab change (no expected tab set)
				vm.currentTab = 2
				await vm.handleTabChange(oldValue: 1, newValue: 2, hasUnlockedPremium: false)

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
