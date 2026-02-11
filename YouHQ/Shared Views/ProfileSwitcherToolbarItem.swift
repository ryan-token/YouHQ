//
//  ProfileSwitcherToolbarItem.swift
//  YouHQ
//
//  Created by Claude Code on 2/11/26.
//

import SQLiteData
import SwiftUI

/// A self-contained toolbar item that allows users to quickly switch between profiles
/// Only appears when the user has multiple profiles
struct ProfileSwitcherToolbarItem: ToolbarContent {
	@FetchAll(Profile.all, animation: .default) var profiles
	@AppStorage(.selectedProfileIDKey) var selectedProfileIDString: String = ""

	private var selectedProfileID: UUID? {
		guard !selectedProfileIDString.isEmpty else { return nil }
		return UUID(uuidString: selectedProfileIDString)
	}

	var body: some ToolbarContent {
		// Only show if there are multiple profiles
		if profiles.count > 1 {
			ToolbarItem(placement: .navigation) {
				Menu {
					VStack {
						HQText("Switch Profiles")
						ForEach(profiles, id: \.id) { profile in
							Button {
								selectedProfileIDString = profile.id.uuidString
								notifyProfileChanged()
							} label: {
								HStack {
									HQText(profile.name)
									if profile.id == selectedProfileID {
										Image(systemName: "checkmark")
									}
								}
							}
						}
					}
				} label: {
					Image(systemName: "shuffle")
				}
			}
		}
	}
}
