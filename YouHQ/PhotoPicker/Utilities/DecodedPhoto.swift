//
//  DecodedPhoto.swift
//  YouHQ
//
//  Created by Ryan Token on 10/23/26.
//

import CoreGraphics
import Foundation

/// A photo's decode progress, for views that decode off the main actor.
enum DecodedPhoto {
	case loading
	case image(CGImage)
	case unavailable

	/// The decoded image's pixel size, once it has loaded.
	var size: CGSize? {
		guard case .image(let image) = self else { return nil }
		return CGSize(width: image.width, height: image.height)
	}

	/// Decodes `data` on the concurrent pool, so large photos never block the main actor.
	@concurrent
	nonisolated static func decode(_ data: Data, maxPixelSize: Int? = nil) async -> DecodedPhoto {
		orientedCGImage(from: data, maxPixelSize: maxPixelSize).map(DecodedPhoto.image) ?? .unavailable
	}
}
