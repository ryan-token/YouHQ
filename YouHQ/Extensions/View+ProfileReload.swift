//
//  View+ProfileReload.swift
//  YouHQ
//
//  Created by Ryan Token on 5/20/26.
//

import Combine
import SwiftUI

extension View {
	/// Reloads when (a) the first profile appears after initial sync, and
	/// (b) the active profile changes via `.profileDidChange`.
	///
	/// Every top-level screen (Home, Vehicles, Money, Media, Career) follows
	/// this pattern, so it lives in one place.
	func reloadOnProfileChange(
		profileCount: Int,
		initialLoad: @escaping () async -> Void,
		onProfileChanged: (() async -> Void)? = nil
	) -> some View {
		let onChange = onProfileChanged ?? initialLoad
		return self
			.onChange(of: profileCount) { oldCount, newCount in
				if oldCount == 0, newCount > 0 {
					Task { await initialLoad() }
				}
			}
			.onReceive(NotificationCenter.default.publisher(for: .profileDidChange)) { _ in
				Task { await onChange() }
			}
	}
}
