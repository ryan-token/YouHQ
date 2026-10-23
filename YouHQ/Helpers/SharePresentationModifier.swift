//
//  SharePresentationModifier.swift
//  YouHQ
//
//  Created by Ryan Token on 1/19/26.
//

#if !os(macOS)
	import CloudKit
	import SQLiteData
	import SwiftUI

	struct SharePresentationModifier: ViewModifier {
		@Binding var sharedRecord: SharedRecord?

		/// Presents a popover where there is room for one and a sheet everywhere else.
		///
		/// A single popover that adapts to a sheet in compact size classes, rather than a device
		/// idiom check: iPhone Duo identifies as a phone but has a regular-width inner display,
		/// and the system re-adapts a presentation that is already up when folding changes the
		/// size class. There is no branch here, so `content` keeps its identity throughout.
		func body(content: Content) -> some View {
			content.popover(item: $sharedRecord) { sharedRecord in
				CloudSharingView(sharedRecord: sharedRecord)
					.presentationCompactAdaptation(.sheet)
			}
		}
	}
#endif
