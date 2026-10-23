//
//  PhotoViewerPresentation.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import Foundation

/// What the photo viewer overlay needs to present.
struct PhotoViewerPresentation {
	let payload: PhotoViewerPayload
	let onClose: () -> Void
}
