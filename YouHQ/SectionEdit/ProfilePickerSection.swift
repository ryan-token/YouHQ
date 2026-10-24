//
//  ProfilePickerSection.swift
//  YouHQ
//
//  Created by Ryan Token on 2/11/26.
//

import SwiftUI

/// A reusable profile picker section that shows a picker for selecting profiles
/// and confirms profile changes with the user before applying them.
struct ProfilePickerSection: View {
	let profiles: [ProfileShare]
	@Binding var selectedProfileID: UUID
	let itemName: String
	let isNewItem: Bool

	/// Profile awaiting confirmation; non-nil while the move alert is shown.
	@State private var pendingProfileID: UUID?

	var body: some View {
		// Only show if there's more than one profile
		if profiles.count > 1 {
			Section("Profile") {
				Picker("Profile", selection: pickerBinding) {
					ForEach(profiles) { profileShare in
						HQText(profileShare.profile.name)
							.tag(profileShare.profile.id)
					}
				}
				.labelsHidden()
			}
			.alert(
				"Move to \(selectedProfileName)?",
				item: $pendingProfileID
			) { newProfileID in
				// Dismissing clears `pendingProfileID`, reverting the picker
				// to the current profile.
				Button("Cancel", role: .cancel) {}
				Button("Move") {
					selectedProfileID = newProfileID
				}
			} message: { _ in
				Text("This will move \(itemName) and all related items to the selected profile.")
			}
		}
	}

	private var pickerBinding: Binding<UUID> {
		Binding(
			get: {
				// Show pending profile if user is in confirmation flow,
				// otherwise show current profile
				pendingProfileID ?? selectedProfileID
			},
			set: { newValue in
				// For new items, just update directly without confirmation
				if isNewItem {
					selectedProfileID = newValue
				} else {
					// For existing items, show confirmation before moving
					if newValue != selectedProfileID {
						pendingProfileID = newValue
					}
				}
			}
		)
	}

	private var selectedProfileName: String {
		if let pendingProfileID,
			let profile = profiles.first(where: { $0.profile.id == pendingProfileID })
		{
			return profile.profile.name
		}
		return ""
	}
}
