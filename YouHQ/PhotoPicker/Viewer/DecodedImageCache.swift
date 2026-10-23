//
//  DecodedImageCache.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import CoreGraphics
import Foundation

/// Remembers the most recently decoded image so a view can read it from `body` without
/// decoding again on every update.
///
/// `ZoomablePhoto` re-evaluates its body for every frame of a pinch or drag, and decoding a
/// full-resolution photo each time made those gestures stutter. Held in `@State` purely as a
/// cache: it is deliberately not observable, because nothing should update when it fills.
final class DecodedImageCache {
	private var cachedData: Data?
	private var cachedImage: CGImage?

	/// The oriented image for `data`, decoding only when `data` differs from the last call.
	func image(for data: Data) -> CGImage? {
		if let cachedData, cachedData == data {
			return cachedImage
		}
		let image = orientedCGImage(from: data)
		cachedData = data
		cachedImage = image
		return image
	}
}
