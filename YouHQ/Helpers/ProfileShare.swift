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
struct ProfileShare {
	let profile: Profile
	let isShared: Bool
	let metadata: SyncMetadata?

	func participantCount() -> Int {
		guard let ckShare = metadata?.share else { return 0 }
		return ckShare.participants.count - 1 // participants count includes yourself, which we don't care about
	}
}
