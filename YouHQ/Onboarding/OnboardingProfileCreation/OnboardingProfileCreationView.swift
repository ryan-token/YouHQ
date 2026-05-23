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
	@Environment(\.accessibilityReduceMotion) private var reduceMotion
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
							.transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
					} else {
						HQText("Let's set up your profile.")
							.font(.title2)
							.fontWeight(.semibold)

						if !vm.hasAnyProfile {
							VStack(alignment: .leading, spacing: 12) {
								Text("A **Profile** holds residences, vehicles, money, media, and career info.")

								Text(
									"""
									**Create additional profiles** to manage data for someone else, \
									or to isolate your own data more cleanly.
									"""
								)

								Text("You can **switch between profiles** at any time.")

								Text(
									"""
									Profiles can be **shared** with others. Sharing a profile \
									with someone else means all data in that profile \
									will be synced seamlessly between all participants.
									"""
								)
							}
							.foregroundStyle(.secondary)
							.fontDesign(.rounded)
						}

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
								vm.isShowingCreateProfileAlert = true
							} label: {
								AddMoreButtonLabel(
									text: vm.hasAnyProfile ? "Create New Profile" : "Create Profile",
									backgroundColor: .indigo
								)
							}
							.buttonStyle(.plain)
						}
					}
				}

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
					.transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
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
		.alert("Create Profile", isPresented: $vm.isShowingCreateProfileAlert) {
			TextField("Profile Name", text: $vm.newProfileName)
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif
			Button {
				vm.createProfile(named: vm.newProfileName)
			} label: {
				HQText("Create")
			}
			.disabled(vm.isProfileNameEmpty)
			Button(role: .cancel) {
				vm.newProfileName = ""
			}
		} message: {
			HQText("Profiles hold residences, vehicles, money, media, and career info.")
		}
		.sheet(isPresented: $vm.showPaywallSheet) {
			Paywall(fromOnboarding: true) {
				Task {
					try? await Task.sleep(for: .seconds(7)) // so the user sees confetti before it dismisses
					vm.showPaywallSheet = false
				}
			}
		}
		.sheet(isPresented: $vm.showAddResidence) {
			if let selectedProfileID = vm.selectedProfileID {
				AddResidenceSheet(profileID: selectedProfileID, selectedResidence: $selectedResidence)
			}
		}
		.sheet(isPresented: $vm.showAddVehicle) {
			if let selectedProfileID = vm.selectedProfileID {
				AddVehicleSheet(profileID: selectedProfileID, selectedVehicle: $selectedVehicle)
			}
		}
		.sheet(isPresented: $vm.showAddJob) {
			if let draftJob {
				SectionEditSheet(section: .jobDraft(draftJob))
			}
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
