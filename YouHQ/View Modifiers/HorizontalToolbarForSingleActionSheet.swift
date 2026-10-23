//
//  HorizontalToolbarForSingleActionSheet.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import SwiftUI

extension View {
	/// Keeps a sheet's toolbar horizontal on iPhone Duo's outer display.
	///
	/// Apply only to sheets whose toolbar is a single Done/Close/Cancel action: a vertical bar
	/// holding one button costs more content width than the horizontal bar it replaces. Every
	/// other screen should keep the system's default vertical-bar adaptation.
	func horizontalToolbarForSingleActionSheet() -> some View {
		modifier(HorizontalToolbarForSingleActionSheet())
	}
}

private struct HorizontalToolbarForSingleActionSheet: ViewModifier {
	func body(content: Content) -> some View {
		// Vertical bars exist only on iOS; the modifier isn't in the macOS or visionOS SDKs.
		#if os(iOS)
			if #available(iOS 27.1, *) {
				content.toolbarVerticalBehavior(.disabled)
			} else {
				content
			}
		#else
			content
		#endif
	}
}
