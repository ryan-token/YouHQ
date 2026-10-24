//
//  OnboardingCongratulationsView.swift
//  YouHQ
//
//  Created by Ryan Token on 2/7/26.
//

import SwiftUI

struct OnboardingCongratulationsView: View {
	@AppStorage("hasLaunchedApp") private var hasLaunchedApp = false

	var body: some View {
		// Scrolls rather than clipping on a short window at large text sizes, and stays
		// vertically centered when it fits.
		ScrollView {
			VStack(spacing: 16) {
				Image(systemName: "checkmark.circle.fill")
					.font(.largeTitle)
					.imageScale(.large)
					.dynamicTypeSize(.xxxLarge)
					.foregroundStyle(.green)
					.accessibilityHidden(true)

				HQText("Congratulations!")
					.font(.largeTitle)
					.fontWeight(.black)

				HQText("You're all set. Enjoy YouHQ!")
					.font(.title2)
					.fontWeight(.semibold)
					.foregroundStyle(.secondary)
			}
			.frame(maxWidth: .infinity)
			.padding()
		}
		.defaultScrollAnchor(.center, for: .alignment)
		.scrollBounceBehavior(.basedOnSize)
		.navigationBarBackButtonHidden(true)
		.task {
			// Leaving before the pause ends (such as choosing another setting while this
			// shows in the Settings detail column) cancels the sleep; don't finish then.
			do {
				try await Task.sleep(for: .seconds(3))
			} catch {
				return
			}
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
