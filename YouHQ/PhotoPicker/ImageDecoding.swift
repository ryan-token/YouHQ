//
//  ImageDecoding.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import ImageIO
import Foundation

func orientedCGImage(from data: Data) -> CGImage? {
	guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
		return nil
	}

	let maxPixelSize = maxPixelSize(from: source)
	var options: [CFString: Any] = [
		kCGImageSourceCreateThumbnailFromImageAlways: true,
		kCGImageSourceCreateThumbnailWithTransform: true,
	]
	if let maxPixelSize {
		options[kCGImageSourceThumbnailMaxPixelSize] = maxPixelSize
	}

	return CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
		?? CGImageSourceCreateImageAtIndex(source, 0, nil)
}

private func maxPixelSize(from source: CGImageSource) -> Int? {
	guard
		let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)
			as? [CFString: Any],
		let width = properties[kCGImagePropertyPixelWidth] as? Int,
		let height = properties[kCGImagePropertyPixelHeight] as? Int
	else {
		return nil
	}

	return max(width, height)
}
