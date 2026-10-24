//
//  PhotoViewerPresentationPreferenceKey.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import SwiftUI

struct PhotoViewerPresentationPreferenceKey: PreferenceKey {
	static let defaultValue: PhotoViewerPresentation? = nil

	static func reduce(
		value: inout PhotoViewerPresentation?,
		nextValue: () -> PhotoViewerPresentation?
	) {
		value = nextValue() ?? value
	}
}
