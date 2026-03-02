//
//  ProfileSwitchingSupport.swift
//  YouHQ
//
//  Created by Ryan Token on 2/11/26.
//

import SQLiteData

/// Helper function to load all profiles from the database
/// This is used by SectionEditViewModel implementations that support profile switching
func loadAllProfiles(from database: any DatabaseReader) -> [ProfileShare] {
	@Dependency(\.context) var context

	if context == .test {
		return (withErrorReporting {
			try database.read { db in
				try Profile.fetchAll(db)
			}
		} ?? []).map { ProfileShare(profile: $0, isShared: false, metadata: nil) }
	}

	return withErrorReporting {
		try database.read { db in
			try Profile
				.group(by: \.id)
				.leftJoin(SyncMetadata.all) {
					$0.syncMetadataID.eq($1.id)
				}
				.select {
					ProfileShare.Columns(
						profile: $0,
						isShared: $1.isShared.ifnull(false),
						metadata: $1
					)
				}
				.fetchAll(db)
		}
	} ?? []
}
