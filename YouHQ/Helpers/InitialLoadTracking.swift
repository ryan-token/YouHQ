//
//  InitialLoadTracking.swift
//  YouHQ
//
//  Created by Ryan Token on 5/20/26.
//

import SwiftUI

/// Tracks completion of a screen's first data load so views can fade in
/// once the underlying SQLiteData queries have populated.
///
/// Conforming view models expose `hasCompletedInitialLoad` and call
/// `markInitialLoadComplete()` after awaiting their initial loads.
protocol InitialLoadTracking: AnyObject {
	var hasCompletedInitialLoad: Bool { get set }
}

extension InitialLoadTracking {
	/// Flips `hasCompletedInitialLoad` to `true` with a fade animation,
	/// after waiting one render window so SwiftUI can observe the Sharing-driven
	/// data updates from `@FetchAll` before the flag changes. Without the
	/// delay, the flag can flip in a render before the fetched arrays
	/// populate, exposing the empty state at full opacity.
	func markInitialLoadComplete() async {
		guard !hasCompletedInitialLoad else { return }
		try? await Task.sleep(for: .milliseconds(90))
		withAnimation(.easeInOut(duration: 0.2)) {
			hasCompletedInitialLoad = true
		}
	}
}
