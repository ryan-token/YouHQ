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

	@State private var pendingProfileID: UUID?
	@State private var showingConfirmation = false

	var body: some View {
		// Only show if there's more than one profile
		if profiles.count > 1 {
			Section("Profile") {
				Picker("Profile", selection: pickerBinding) {
					ForEach(profiles, id: \.profile.id) { profileShare in
						HQText(profileShare.profile.name)
							.tag(profileShare.profile.id)
					}
				}
				.labelsHidden()
			}
			.alert(
				"Move to \(selectedProfileName)?",
				isPresented: $showingConfirmation
			) {
				Button("Cancel", role: .cancel) {
					// Revert to original profile
					pendingProfileID = nil
				}
				Button("Move") {
					// Apply the change
					if let newProfileID = pendingProfileID {
						selectedProfileID = newProfileID
					}
					pendingProfileID = nil
				}
			} message: {
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
						showingConfirmation = true
					}
				}
			}
		)
	}

	private var selectedProfileName: String {
		if let pendingID = pendingProfileID,
			let profile = profiles.first(where: { $0.profile.id == pendingID })
		{
			return profile.profile.name
		}
		return ""
	}
}
