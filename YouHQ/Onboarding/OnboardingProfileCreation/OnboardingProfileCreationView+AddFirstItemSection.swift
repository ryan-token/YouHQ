//
//  OnboardingProfileCreationView+AddFirstItemSection.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import SwiftUI

extension OnboardingProfileCreationView {
	/// Offered once the profile exists: a first residence, vehicle, or job.
	struct AddFirstItemSection: View {
		@Environment(PaywallManager.self) private var paywallManager

		let vm: ViewModel

		var body: some View {
			VStack(alignment: .leading, spacing: 12) {
				HQText("Now add your first residence, vehicle, or job:")
					.fontWeight(.medium)
					.padding(.bottom, 4)

				OnboardingButton(
					action: addResidence,
					text: "Add Residence",
					iconName: "house.fill",
					backgroundColor: .indigo
				)

				OnboardingButton(
					action: addVehicle,
					text: "Add Vehicle",
					iconName: "car.fill",
					backgroundColor: .teal
				)

				OnboardingButton(
					action: addJob,
					text: "Add Job",
					iconName: "briefcase.fill",
					backgroundColor: .blue
				)
			}
		}

		private func addResidence() {
			vm.addResidence(hasUnlockedPremium: paywallManager.hasUnlockedPremium)
		}

		private func addVehicle() {
			vm.addVehicle(hasUnlockedPremium: paywallManager.hasUnlockedPremium)
		}

		private func addJob() {
			vm.addJob(hasUnlockedPremium: paywallManager.hasUnlockedPremium)
		}
	}
}
