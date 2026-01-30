//
//  DatabaseWriter+EnsureDefaultProfile.swift
//  YouHQ
//
//  Created by Ryan Token on 1/13/26.
//

import Foundation
import SQLiteData

extension DatabaseWriter {
	/// Creates a default "Default" profile if none exist
	/// Returns the UUID of the Default profile
	@discardableResult
	func ensureDefaultProfile() throws -> UUID {
		try write { db in
			let profiles = try Profile.fetchAll(db)
			if let defaultProfile = profiles.first(where: { $0.name == "Default" }) {
				return defaultProfile.id
			}

			@Dependency(\.date.now) var now
			let profileID = UUID()

			try db.seed {
				Profile.Draft(
					id: profileID,
					name: "Default",
					createdAt: now,
					updatedAt: now
				)
			}

			print("✅ Default profile created successfully")
			return profileID
		}
	}
}
