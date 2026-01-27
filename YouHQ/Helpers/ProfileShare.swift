//
//  ProfileShare.swift
//  YouHQ
//
//  Created by Ryan Token on 1/26/26.
//

import SQLiteData

// Join: Get all profiles and whether they are shared or not
@Selection
struct ProfileShare {
	let profile: Profile
	let isShared: Bool
}
