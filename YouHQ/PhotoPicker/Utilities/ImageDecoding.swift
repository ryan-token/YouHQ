//
//  ImageDecoding.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import Foundation
import ImageIO

/// Decodes `data` upright, downsampled so its longer side is at most `maxPixelSize` pixels,
/// or at full size when `maxPixelSize` is `nil`.
nonisolated func orientedCGImage(from data: Data, maxPixelSize: Int? = nil) -> CGImage? {
	guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
		return nil
	}

	var options: [CFString: Any] = [
		kCGImageSourceCreateThumbnailFromImageAlways: true,
		kCGImageSourceCreateThumbnailWithTransform: true
	]
	if let pixelSize = pixelSize(of: source) {
		let fullSize = Int(max(pixelSize.width, pixelSize.height))
		options[kCGImageSourceThumbnailMaxPixelSize] = min(maxPixelSize ?? fullSize, fullSize)
	}

	return CGImageSourceCreateThumbnailAtIndex(
		source,
		0,
		options as CFDictionary
	)
		?? CGImageSourceCreateImageAtIndex(source, 0, nil)
}

/// The size `data` displays at once its orientation is applied, read from the image header
/// without decoding pixels.
nonisolated func orientedPixelSize(of data: Data) -> CGSize? {
	guard let source = CGImageSourceCreateWithData(data as CFData, nil),
		let size = pixelSize(of: source)
	else {
		return nil
	}

	// EXIF orientations 5 through 8 rotate the image a quarter turn.
	let orientation =
		(CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any])?[kCGImagePropertyOrientation]
		as? Int ?? 1
	return orientation >= 5 ? CGSize(width: size.height, height: size.width) : size
}

private nonisolated func pixelSize(of source: CGImageSource) -> CGSize? {
	guard
		let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)
			as? [CFString: Any],
		let width = properties[kCGImagePropertyPixelWidth] as? Int,
		let height = properties[kCGImagePropertyPixelHeight] as? Int,
		width > 0, height > 0
	else {
		return nil
	}

	return CGSize(width: width, height: height)
}
