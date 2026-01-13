//
//  DatabaseWriter+EnsureDefaultProfile.swift
//  YouHQ
//
//  Created by Ryan Token on 1/13/26.
//

import SQLiteData

extension DatabaseWriter {
	/// Creates a default "Default" profile if none exist
	func ensureDefaultProfile() throws {
		try write { db in
			let profiles = try Profile.fetchAll(db)
			let defaultProfile = profiles.first(where: { $0.name == "Default" })
			if defaultProfile != nil { return }

			@Dependency(\.date.now) var now

			try db.seed {
				Profile.Draft(
					name: "Default",
					createdAt: now,
					updatedAt: now
				)
			}

			print("✅ Default profile created successfully")
		}
	}
}
