//
//  NotificationSettingsView.swift
//  YouHQ
//
//  Created by Ryan Token on 3/10/26.
//

import SwiftUI

struct NotificationSettingsView: View {
	@Environment(\.scenePhase) private var scenePhase
	@State private var vm = ViewModel()

	var body: some View {
		List {
			Section {
				HStack {
					HQText("Permission Status")
						.foregroundStyle(.secondary)
					Spacer()
					HQText(vm.permissionStatusText)
						.foregroundStyle(vm.isAuthorized ? .green : .red)
				}
				.listRowSeparator(.hidden)

				if !vm.isAuthorized {
					Button {
						NotificationManager.shared.openNotificationSettings()
					} label: {
						HQText("Open Notification Settings")
					}
				}
			} header: {
				HQText("Notification Permissions")
			}

			Section {
				LabeledField("Remind Me", shouldOverrideTap: false) {
					Picker(selection: $vm.selectedInterval) {
						ForEach(ReminderInterval.allCases, id: \.self) { interval in
							HQText(interval.displayName).tag(interval)
						}
					} label: {
						EmptyView()
					}
					.tint(.indigo)
				}
			} header: {
				HQText("Info Update Reminder")
			} footer: {
				HQText(
					"Get a recurring notification as a reminder to keep your info up to date."
				)
				.listRowSeparator(.hidden)
			}

			VStack(alignment: .leading, spacing: 12) {
				Text("Use **Notifications** as reminders to update your info on a regular schedule.")

				Text("You can also set notifications on **maintenance items** for your residences and vehicles.")
			}
			.fontDesign(.rounded)
			.foregroundStyle(.secondary)
			.listRowBackground(Color.clear)
			.listRowSeparator(.hidden)
			.padding(.top)
		}
		.contentMargins(.top, 0)
		.navigationTitle("Notifications")
		#if !os(macOS)
			.navigationBarTitleDisplayMode(.inline)
		#endif
		.task {
			await vm.loadData()
		}
		.onChange(of: scenePhase) {
			if scenePhase == .active {
				Task { await vm.refreshPermissions() }
			}
		}
		.onChange(of: vm.selectedInterval) {
			Task {
				await vm.handleIntervalChange()
			}
		}
		.alert(
			"Notifications Disabled",
			isPresented: $vm.isShowingPermissionAlert
		) {
			Button("Open Settings") {
				NotificationManager.shared.openNotificationSettings()
			}
			Button("Cancel", role: .cancel) {
				vm.revertInterval()
			}
		} message: {
			HQText(
				"To receive update reminders, please enable notifications in Settings."
			)
		}
	}
}

#Preview {
	NavigationStack {
		NotificationSettingsView()
	}
}
