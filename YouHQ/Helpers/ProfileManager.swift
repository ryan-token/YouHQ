//
//  ProfileManager.swift
//  YouHQ
//
//  Created by Ryan Token on 1/30/26.
//

import Foundation
import SQLiteData
import SwiftUI

/// Protocol for view models that need profile selection
protocol ProfileSelection: AnyObject {
	var profiles: [ProfileShare] { get }
	var selectedProfileIDString: String { get }
	func setSelectedProfileIDString(_ value: String)
}

extension ProfileSelection {
	/// Reads the selected profile ID as a `UUID?`.
	var currentProfileID: UUID? {
		guard !selectedProfileIDString.isEmpty else { return nil }
		return UUID(uuidString: selectedProfileIDString)
	}

	/// Writes the selected profile ID.
	func setCurrentProfileID(_ newValue: UUID?) {
		setSelectedProfileIDString(newValue?.uuidString ?? "")
	}

	/// Gets the selected profile with fallback logic.
	func getSelectedProfile() -> ProfileShare? {
		let profileID = getSelectedProfileID()
		return profiles.first(where: { $0.profile.id == profileID })
	}

	/// Gets the selected profile ID with fallback logic.
	/// Falls back to: stored ID -> first available
	func getSelectedProfileID() -> UUID? {
		// Try stored profile
		if let storedID = currentProfileID,
			profiles.contains(where: { $0.profile.id == storedID })
		{
			return storedID
		}

		// Fall back to first available profile
		if let firstProfile = profiles.first {
			setCurrentProfileID(firstProfile.profile.id)
			return firstProfile.profile.id
		}

		return nil
	}
}

// MARK: - AppStorage Key

extension String {
	static let selectedProfileIDKey = "selectedProfileID"
}

// MARK: - Profile Change Notification

extension Notification.Name {
	static let profileDidChange = Notification.Name("profileDidChange")
}

/// Posts a notification when the profile changes
func notifyProfileChanged() {
	NotificationCenter.default.post(name: .profileDidChange, object: nil)
}
