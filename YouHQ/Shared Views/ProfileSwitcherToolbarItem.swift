//
//  ProfileSwitcherToolbarItem.swift
//  YouHQ
//
//  Created by Ryan Token on 2/11/26.
//

import SQLiteData
import SwiftUI

/// A self-contained toolbar item that allows users to quickly switch between profiles
/// Only appears when the user has multiple profiles
struct ProfileSwitcherToolbarItem: ToolbarContent {
	@FetchAll(Profile.all, animation: .default) private var profiles
	@AppStorage(.selectedProfileIDKey) private var selectedProfileIDString: String = ""

	private var selectedProfileID: UUID? {
		guard !selectedProfileIDString.isEmpty else { return nil }
		return UUID(uuidString: selectedProfileIDString)
	}

	var body: some ToolbarContent {
		// Only show if there are multiple profiles
		if profiles.count > 1 {
			ToolbarItem(placement: .navigation) {
				// A title as well as a symbol: iPhone Duo's vertical bar shows the symbol, and the
				// overflow menu it collapses into shows the title.
				Menu("Switch Profile", systemImage: "person.2.square.stack") {
					Section("Switch Profiles") {
						ForEach(profiles) { profile in
							Button {
								select(profile)
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
				}
			}
		}
	}

	private func select(_ profile: Profile) {
		selectedProfileIDString = profile.id.uuidString
		notifyProfileChanged()
	}
}
