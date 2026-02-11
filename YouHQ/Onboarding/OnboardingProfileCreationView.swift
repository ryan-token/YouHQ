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

	@State private var showAddResidence = false
	@State private var showAddVehicle = false
	@State private var showAddJob = false
	@State private var selectedResidence: Residence?
	@State private var selectedVehicle: Vehicle?
	@State private var draftJob: Job?
	@State private var showCreateProfileSheet = false
	@State private var hasAnyProfile = false
	@State private var createdNewProfile = false
	@State private var createdProfileName = ""

	@AppStorage("selectedProfileID") private var selectedProfileIDString: String = ""

	private var selectedProfileID: UUID? {
		UUID(uuidString: selectedProfileIDString)
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
				do {
					let savedJob = try database.read { db in
						try Job.find(draftJob.id).fetchOne(db)
					}
					if savedJob != nil {
						onComplete()
					}
				} catch {
					print("Error checking job existence: \(error)")
				}
			}
		}
	}

	private func checkForProfile() async {
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
}

#Preview {
	OnboardingProfileCreationView(onComplete: {})
}
