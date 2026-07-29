//
//  ProfileShare.swift
//  YouHQ
//
//  Created by Ryan Token on 1/26/26.
//

import CloudKit
import SQLiteData
import SwiftUI

// Join: Get all profiles, whether they are shared or not, and the sync metadata for shared participants
@Selection
nonisolated struct ProfileShare: Identifiable {
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

nonisolated extension ProfileShare {
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

	/// Loads `allWithSyncMetadata` into a deferred `@FetchAll(ProfileShare.none)` projection.
	///
	/// Profile-switching view models declare `@FetchAll(ProfileShare.none) var profiles` so the
	/// query is empty until the view appears, then call this in a `.task { }` to hydrate it.
	static func reload(into fetchAll: FetchAll<ProfileShare>) async {
		_ = await withErrorReporting {
			try await fetchAll.load(ProfileShare.allWithSyncMetadata, animation: .default)
		}
	}
}
