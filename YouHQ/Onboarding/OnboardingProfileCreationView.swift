//
//  OnboardingProfileCreationView.swift
//  YouHQ
//
//  Created by Ryan Token on 2/10/26.
//

import SQLiteData
import SwiftUI

struct OnboardingProfileCreationView: View {
	@Dependency(\.defaultDatabase) private var database
	@Environment(PaywallManager.self) private var paywallManager

	@State private var showAddResidence = false
	@State private var showAddVehicle = false
	@State private var showAddJob = false
	@State private var selectedResidence: Residence?
	@State private var selectedVehicle: Vehicle?
	@State private var draftJob: Job?
	@State private var showCreateProfileSheet = false
	@State private var showPaywallSheet = false
	@State private var hasAnyProfile = false
	@State private var existingProfileName = ""
	@State private var createdNewProfile = false
	@State private var createdProfileName = ""

	@AppStorage("selectedProfileID") private var selectedProfileIDString: String = ""

	private var selectedProfileID: UUID? {
		UUID(uuidString: selectedProfileIDString)
	}

	private var isFreeTierLimited: Bool {
		hasAnyProfile && !paywallManager.hasUnlockedPremium
	}

	var onComplete: () -> Void

	var body: some View {
		ScrollView {
			VStack(spacing: 18) {
				VStack(alignment: .leading, spacing: 12) {
					if createdNewProfile {
						HQText("Profile \"\(createdProfileName)\" created!")
							.font(.title2)
							.fontWeight(.semibold)
							.frame(maxWidth: .infinity, alignment: .leading)
					} else {
						HQText("Let's set up your profile.")
							.font(.title2)
							.fontWeight(.semibold)

						HQText("Profiles hold residences, vehicles, money, media, and career info.")
							.foregroundStyle(.secondary)

						// Show limitation card if free user has existing profile
						if hasAnyProfile && !paywallManager.hasUnlockedPremium {
							freeTierLimitationCard
						}

						// Button logic: Subscribe for free users with profile, Create for others
						if hasAnyProfile && !paywallManager.hasUnlockedPremium {
							Button {
								showPaywallSheet = true
							} label: {
								HQText("Subscribe to Create More Profiles")
									.fontWeight(.medium)
									.frame(maxWidth: .infinity)
							}
							.buttonStyle(.borderedProminent)
							.controlSize(.large)
						} else {
							Button {
								showCreateProfileSheet = true
							} label: {
								HQText(hasAnyProfile ? "Create New Profile" : "Create Profile")
									.fontWeight(.medium)
									.frame(maxWidth: .infinity)
							}
							.buttonStyle(.borderedProminent)
							.controlSize(.large)
						}
					}
				}

				// Show "Get started" section only if user created a new profile
				if createdNewProfile {
					VStack(alignment: .leading, spacing: 12) {
						HQText("Now add your first residence, vehicle, or job:")
							.fontWeight(.medium)
							.padding(.bottom, 4)

						OnboardingButton(
							action: { showAddResidence = true },
							text: "Add Residence",
							iconName: "house.fill",
							backgroundColor: .indigo
						)

						OnboardingButton(
							action: { showAddVehicle = true },
							text: "Add Vehicle",
							iconName: "car.fill",
							backgroundColor: .teal
						)

						OnboardingButton(
							action: {
								if let selectedProfileID {
									draftJob = Job(id: UUID(), profileID: selectedProfileID)
									showAddJob = true
								}
							},
							text: "Add Job",
							iconName: "briefcase.fill",
							backgroundColor: .blue
						)
					}
				}

				// Show Skip button if user has any profiles
				if hasAnyProfile {
					Button {
						onComplete()
					} label: {
						HQText("Skip")
							.fontWeight(.medium)
					}
					.frame(maxWidth: .infinity, alignment: .center)
					.padding(.bottom, 24)
				}

				VStack(alignment: .leading, spacing: 0) {
					HQText("You will be able to add more data later.")
						.foregroundStyle(.secondary)

					Link(
						"Privacy Policy",
						destination: Constants.privacyPolicyURL
					)
					.foregroundStyle(.accent)
				}
				.font(.callout)
				.fontWeight(.medium)
				.frame(maxWidth: .infinity, alignment: .leading)

				Spacer()
			}
			.padding()
			.padding(.horizontal, 8)
		}
		.toolbar(removing: .title)
		.task {
			await checkForProfile()
		}
		.onReceive(NotificationCenter.default.publisher(for: .profileDidChange)) { _ in
			Task {
				await checkForProfile()
			}
		}
		.sheet(
			isPresented: $showCreateProfileSheet,
			onDismiss: {
				Task {
					await checkForProfile()
				}
			}
		) {
			OnboardingProfileSetup(
				createdNewProfile: $createdNewProfile,
				createdProfileName: $createdProfileName
			)
		}
		.sheet(isPresented: $showPaywallSheet) {
			Paywall(fromOnboarding: true) {
				Task {
					try? await Task.sleep(for: .seconds(7)) // so the user sees confetti before it dismisses
					showPaywallSheet = false
				}
			}
		}
		.sheet(isPresented: $showAddResidence) {
			if let selectedProfileID {
				AddResidenceSheet(profileID: selectedProfileID, selectedResidence: $selectedResidence)
			}
		}
		.sheet(isPresented: $showAddVehicle) {
			if let selectedProfileID {
				AddVehicleSheet(profileID: selectedProfileID, selectedVehicle: $selectedVehicle)
			}
		}
		.sheet(isPresented: $showAddJob) {
			SectionEditSheet(section: .jobDraft, draftJob: $draftJob)
		}
		.onChange(of: selectedResidence) { _, newValue in
			if newValue != nil { onComplete() }
		}
		.onChange(of: selectedVehicle) { _, newValue in
			if newValue != nil { onComplete() }
		}
		.onChange(of: showAddJob) { _, isShowing in
			// When job sheet dismisses, check if a job was saved
			if !isShowing, let draftJob {
				Task {
					do {
						let savedJob = try await database.read { db in
							try Job.find(draftJob.id).fetchOne(db)
						}
						if savedJob != nil {
							onComplete()
						}
					} catch {
						Analytics.logError(id: .jobSaveVerificationFailed, message: error.localizedDescription)
					}
				}
			}
		}
	}

	@ViewBuilder
	private var freeTierLimitationCard: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack(spacing: 8) {
				Image(systemName: "person.circle.fill")
					.foregroundStyle(.indigo)
					.font(.largeTitle)

				VStack(alignment: .leading, spacing: 0) {
					HQText("You already have a profile")
						.font(.headline)
						.fontWeight(.semibold)

					HQText("Profile: \(existingProfileName)")
						.foregroundStyle(.secondary)
						.font(.subheadline)
				}
			}

			Text(
				"""
				The free version of YouHQ allows \(Constants.profilesThreshold) profile. \
				To create additional profiles, subscribe to **YouHQ Premium**.
				"""
			)
			.foregroundStyle(.secondary)
			.font(.callout)
			.fontDesign(.rounded)
		}
		.padding(12)
		.background(.quinary, in: .rect(cornerRadius: 24))
	}

	private func checkForProfile() async {
		do {
			let profiles = try await database.read { db in
				try Profile.fetchAll(db)
			}
			hasAnyProfile = !profiles.isEmpty
			existingProfileName = profiles.first?.name ?? ""
		} catch {
			print("Error checking for profiles: \(error)")
			hasAnyProfile = false
			existingProfileName = ""
		}
	}
}

#Preview {
	OnboardingProfileCreationView(onComplete: {})
		.environment(PaywallManager())
}
