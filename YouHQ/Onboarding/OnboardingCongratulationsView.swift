//
//  OnboardingCongratulationsView.swift
//  YouHQ
//
//  Created by Ryan Token on 2/7/26.
//

import SwiftUI

struct OnboardingCongratulationsView: View {
	@AppStorage("hasLaunchedApp") var hasLaunchedApp = false
	@Environment(\.dismiss) var dismiss

	var body: some View {
		VStack(spacing: 32) {
			Spacer()

			VStack(spacing: 16) {
				Image(systemName: "checkmark.circle.fill")
					.font(.system(.largeTitle))
					.imageScale(.large)
					.dynamicTypeSize(.xxxLarge)
					.foregroundStyle(.green)

				HQText("Congratulations!")
					.font(.largeTitle)
					.fontWeight(.black)

				HQText("You're all set. Enjoy YouHQ!")
					.font(.title2)
					.fontWeight(.semibold)
					.foregroundStyle(.secondary)
			}

			Spacer()
		}
		.navigationBarBackButtonHidden(true)
		.padding()
		.task {
			try? await Task.sleep(for: .seconds(3))
			withAnimation {
				hasLaunchedApp = true
				notifyOnboardingCompleted()
			}
		}
	}
}

extension Notification.Name {
	static let onboardingCompleted = Notification.Name("onboardingCompleted")
}

/// Posts a notification when the profile changes
func notifyOnboardingCompleted() {
	NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
}

#Preview {
	OnboardingCongratulationsView()
}
