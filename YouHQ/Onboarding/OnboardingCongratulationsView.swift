//
//  OnboardingCongratulationsView.swift
//  YouHQ
//
//  Created by Ryan Token on 2/7/26.
//

import Combine
import SwiftUI

struct OnboardingCongratulationsView: View {
	@AppStorage("hasLaunchedApp") var hasLaunchedApp = false
	@Environment(\.dismiss) var dismiss
	@State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	@State private var countdown = 3

	var body: some View {
		VStack(spacing: 32) {
			Spacer()

			VStack(spacing: 16) {
				Image(systemName: "checkmark.circle.fill")
					.font(.system(size: 80))
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
		.onReceive(timer) { _ in
			if countdown > 0 {
				countdown -= 1
			} else {
				withAnimation {
					hasLaunchedApp = true
					notifyOnboardingCompleted()
				}
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
