//
//  ProfileShare.swift
//  YouHQ
//
//  Created by Ryan Token on 1/26/26.
//

import CloudKit
import SQLiteData

// Join: Get all profiles, whether they are shared or not, and the sync metadata for shared participants
@Selection
struct ProfileShare: Identifiable {
	let profile: Profile
	let isShared: Bool
	let metadata: SyncMetadata?

	var id: Profile.ID { profile.id }

	func participantCount() -> Int {
		guard let ckShare = metadata?.share else { return 0 }
		return ckShare.participants.count - 1 // participants count includes yourself, which we don't care about
	}
}

// MARK: - Shared query

extension ProfileShare {
	/// Joins `Profile` with `SyncMetadata` so every profile is returned alongside
	/// its sharing state. Pass to `$profiles.load(...)` in view models.
	static var allWithSyncMetadata: some StructuredQueriesCore.Statement<ProfileShare> & Sendable {
		Profile
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
	}
}
