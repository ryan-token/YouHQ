//
//  OnboardingProfileCreationView.swift
//  YouHQ
//
//  Created by Ryan Token on 2/10/26.
//

import SQLiteData
import SwiftUI

struct OnboardingProfileCreationView: View {
	@Environment(PaywallManager.self) private var paywallManager
	@State private var vm = ViewModel()

	@State private var selectedResidence: Residence?
	@State private var selectedVehicle: Vehicle?
	@State private var draftJob: Job?

	var onComplete: () -> Void

	var body: some View {
		ScrollView {
			VStack(spacing: 18) {
				VStack(alignment: .leading, spacing: 12) {
					if vm.createdNewProfile {
						HQText("Profile \"\(vm.createdProfileName)\" created!")
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
						if vm.hasAnyProfile && !paywallManager.hasUnlockedPremium {
							FreeTierLimitationCard(profileName: vm.existingProfileName)
						}

						// Button logic: Subscribe for free users with profile, Create for others
						if vm.hasAnyProfile && !paywallManager.hasUnlockedPremium {
							Button {
								vm.showPaywallSheet = true
							} label: {
								HQText("Subscribe to Create More Profiles")
									.fontWeight(.medium)
									.frame(maxWidth: .infinity)
							}
							.buttonStyle(.borderedProminent)
							.controlSize(.large)
						} else {
							Button {
								vm.showCreateProfileSheet = true
							} label: {
								HQText(vm.hasAnyProfile ? "Create New Profile" : "Create Profile")
									.fontWeight(.medium)
									.frame(maxWidth: .infinity)
							}
							.buttonStyle(.borderedProminent)
							.controlSize(.large)
						}
					}
				}

				// Show "Get started" section only if user created a new profile
				if vm.createdNewProfile {
					VStack(alignment: .leading, spacing: 12) {
						HQText("Now add your first residence, vehicle, or job:")
							.fontWeight(.medium)
							.padding(.bottom, 4)

						OnboardingButton(
							action: {
								if paywallManager.hasUnlockedPremium || vm.residencesCount < Constants.paywallResidencesThreshold {
									vm.showAddResidence = true
								} else {
									vm.showPaywallSheet = true
								}
							},
							text: "Add Residence",
							iconName: "house.fill",
							backgroundColor: .indigo
						)

						OnboardingButton(
							action: {
								if paywallManager.hasUnlockedPremium || vm.vehiclesCount < Constants.paywallVehiclesThreshold {
									vm.showAddVehicle = true
								} else {
									vm.showPaywallSheet = true
								}
							},
							text: "Add Vehicle",
							iconName: "car.fill",
							backgroundColor: .teal
						)

						OnboardingButton(
							action: {
								if let selectedProfileID = vm.selectedProfileID {
									if paywallManager.hasUnlockedPremium || vm.jobsCount < Constants.paywallCoreItemsThreshold {
										draftJob = Job(id: UUID(), profileID: selectedProfileID)
										vm.showAddJob = true
									} else {
										vm.showPaywallSheet = true
									}
								}
							},
							text: "Add Job",
							iconName: "briefcase.fill",
							backgroundColor: .blue
						)
					}
				}

				// Show Skip button if user has any profiles
				if vm.hasAnyProfile {
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
			await vm.checkForProfile()
		}
		.onReceive(NotificationCenter.default.publisher(for: .profileDidChange)) { _ in
			Task {
				await vm.checkForProfile()
			}
		}
		.sheet(
			isPresented: $vm.showCreateProfileSheet,
			onDismiss: {
				Task {
					await vm.checkForProfile()
				}
			}
		) {
			OnboardingProfileSetup(
				createdNewProfile: $vm.createdNewProfile,
				createdProfileName: $vm.createdProfileName
			)
		}
		.sheet(isPresented: $vm.showPaywallSheet) {
			Paywall(fromOnboarding: true) {
				Task {
					try? await Task.sleep(for: .seconds(7)) // so the user sees confetti before it dismisses
					vm.showPaywallSheet = false
				}
			}
		}
		.sheet(isPresented: Binding(
			get: { vm.showAddResidence && vm.selectedProfileID != nil },
			set: { vm.showAddResidence = $0 }
		)) {
			if let selectedProfileID = vm.selectedProfileID {
				AddResidenceSheet(profileID: selectedProfileID, selectedResidence: $selectedResidence)
			}
		}
		.sheet(isPresented: Binding(
			get: { vm.showAddVehicle && vm.selectedProfileID != nil },
			set: { vm.showAddVehicle = $0 }
		)) {
			if let selectedProfileID = vm.selectedProfileID {
				AddVehicleSheet(profileID: selectedProfileID, selectedVehicle: $selectedVehicle)
			}
		}
		.sheet(isPresented: $vm.showAddJob) {
			SectionEditSheet(section: .jobDraft, draftJob: $draftJob)
		}
		.onChange(of: selectedResidence) { _, newValue in
			if newValue != nil { onComplete() }
		}
		.onChange(of: selectedVehicle) { _, newValue in
			if newValue != nil { onComplete() }
		}
		.onChange(of: vm.showAddJob) { _, isShowing in
			// When job sheet dismisses, check if a job was saved
			if !isShowing, let draftJob {
				Task {
					let wasSaved = await vm.checkIfJobWasSaved(jobID: draftJob.id)
					if wasSaved {
						onComplete()
					}
				}
			}
		}
	}
}

#Preview {
	OnboardingProfileCreationView(onComplete: {})
		.environment(PaywallManager())
}
