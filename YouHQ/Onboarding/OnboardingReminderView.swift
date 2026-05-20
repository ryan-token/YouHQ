//
//  OnboardingReminderView.swift
//  YouHQ
//
//  Created by Ryan Token on 3/10/26.
//

import SwiftUI

struct OnboardingReminderView: View {
	@State private var vm = ViewModel()

	var onComplete: () -> Void

	var body: some View {
		ScrollView {
			VStack(spacing: 24) {
				VStack(alignment: .leading, spacing: 12) {
					HQText("Stay Up to Date")
						.font(.title2)
						.fontWeight(.semibold)

					HQText(
						"YouHQ works best when your info is current. Would you like to be reminded to review and update your data?"
					)
					.foregroundStyle(.secondary)
				}
				.frame(maxWidth: .infinity, alignment: .leading)

				HStack {
					HQText("Remind me")
					Picker("", selection: $vm.selectedInterval) {
						ForEach(ReminderInterval.allCases, id: \.self) { interval in
							HQText(interval.displayName).tag(interval)
						}
					}
					.labelsHidden()
					Spacer()
				}
				.fontWeight(.medium)

				if vm.selectedInterval != .none {
					VStack(alignment: .leading, spacing: 6) {
						OnboardingButton(
							action: {
								Task {
									await vm.enableReminder()
									if !vm.isShowingPermissionAlert {
										onComplete()
									}
								}
							},
							text: vm.enableButtonText,
							iconName: "bell.fill",
							backgroundColor: .green
						)

						HQText("You can change this later in Settings")
							.font(.footnote)
							.foregroundStyle(.secondary)
					}
				}

				Button {
					onComplete()
				} label: {
					HQText("Skip")
						.fontWeight(.medium)
				}
				.frame(maxWidth: .infinity, alignment: .center)
				.padding(.bottom, 24)

				Spacer()
			}
			.padding()
			.padding(.horizontal, 8)
		}
		.task { vm.loadData() }
		.toolbar(removing: .title)
		.alert(
			"Notifications Disabled",
			isPresented: $vm.isShowingPermissionAlert
		) {
			Button("Open Settings") {
				NotificationManager.shared.openNotificationSettings()
			}
			Button("Cancel", role: .cancel) {}
		} message: {
			HQText(
				"To receive update reminders, please enable notifications in Settings."
			)
		}
	}
}

#Preview {
	OnboardingReminderView(onComplete: {})
}
