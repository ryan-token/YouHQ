//
//  OnboardingEndView.swift
//  YouHQ
//
//  Created by Ryan Token on 2/7/26.
//

import SQLiteData
import SwiftUI

struct OnboardingEndView: View {
	@AppStorage("hasLaunchedApp") var hasLaunchedApp = false
	@Dependency(\.defaultDatabase) private var database
	@Environment(\.colorScheme) var colorScheme

	@State private var showAddResidence = false
	@State private var showAddVehicle = false
	@State private var showAddJob = false
	@State private var selectedResidence: Residence?
	@State private var selectedVehicle: Vehicle?
	@State private var draftJob: Job?
	@State private var profileID: UUID?
	@State private var showCongratulations = false

	var onComplete: () -> Void

	var body: some View {
		ScrollView {
			VStack(spacing: 18) {
				VStack(alignment: .leading, spacing: 12) {
					HQText("YouHQ is your personal command center for life's important details.")
					HQText(
						"Track everything from home maintenance and vehicles to career history and where all of your money is, all in one place."
					)
					HQText(
						"""
						🔒 Your data is your own. All of your data stays on your devices \
						and is synced securely over iCloud via your Apple Account.
						""")
				}
				.foregroundStyle(.secondary)
				.frame(maxWidth: .infinity, alignment: .leading)

				VStack(alignment: .leading, spacing: 12) {
					HQText("Get started by adding a residence, a vehicle, or a job:")
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
							if let profileID {
								draftJob = createDraft(for: profileID)
								showAddJob = true
							}
						},
						text: "Add Job",
						iconName: "briefcase.fill",
						backgroundColor: .blue
					)

					Button {
						showCongratulations = true
					} label: {
						HQText("Skip")
							.fontWeight(.medium)
					}
					.frame(maxWidth: .infinity, alignment: .center)
					.padding(.bottom, 24)
				}

				VStack(alignment: .leading, spacing: 0){
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
		.onAppear {
			profileID = try? database.ensureDefaultProfile()
		}
		.sheet(isPresented: $showAddResidence) {
			if let profileID {
				AddResidenceSheet(profileID: profileID, selectedResidence: $selectedResidence)
			}
		}
		.sheet(isPresented: $showAddVehicle) {
			if let profileID {
				AddVehicleSheet(profileID: profileID, selectedVehicle: $selectedVehicle)
			}
		}
		.sheet(isPresented: $showAddJob) {
			SectionEditSheet(section: .jobDraft, draftJob: $draftJob)
		}
		.onChange(of: selectedResidence) {
			if selectedResidence != nil {
				showCongratulations = true
			}
		}
		.onChange(of: selectedVehicle) {
			if selectedVehicle != nil {
				showCongratulations = true
			}
		}
		.onChange(of: showAddJob) { _, isShowing in
			// When job sheet dismisses, check if a job was saved
			if !isShowing, let draftJob {
				do {
					let savedJob = try database.read { db in
						try Job.find(draftJob.id).fetchOne(db)
					}
					if savedJob != nil {
						showCongratulations = true
					}
				} catch {
					print("Error checking job existence: \(error)")
				}
			}
		}
		.onChange(of: showCongratulations) {
			if showCongratulations {
				onComplete()
			}
		}
	}

	private func createDraft(for profileID: UUID) -> Job {
		Job(
			id: UUID(),
			profileID: profileID
		)
	}
}

#Preview {
	OnboardingEndView(onComplete: {})
}
