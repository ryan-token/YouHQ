//
//  CameraPresentationPreferenceKey.swift
//  YouHQ
//
//  Created by Ryan Token on 1/18/26.
//

#if os(iOS)
	import SwiftUI

	struct CameraPresentationPreferenceKey: PreferenceKey {
		static let defaultValue: CameraPresentation? = nil

		static func reduce(
			value: inout CameraPresentation?,
			nextValue: () -> CameraPresentation?
		) {
			value = nextValue() ?? value
		}
	}
#endif
