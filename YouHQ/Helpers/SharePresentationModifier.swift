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

		func body(content: Content) -> some View {
			if UIDevice.current.userInterfaceIdiom == .phone {
				content.sheet(item: $sharedRecord) { sharedRecord in
					CloudSharingView(sharedRecord: sharedRecord)
				}
			} else {
				content.popover(item: $sharedRecord) { sharedRecord in
					CloudSharingView(sharedRecord: sharedRecord)
				}
			}
		}
	}
#endif
