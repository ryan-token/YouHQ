//
//  PhotoThumbnail.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import SwiftUI

struct PhotoThumbnail: View {
	let data: Data

	// Decodes once per photo rather than on every body evaluation.
	@State private var imageCache = DecodedImageCache()

	var body: some View {
		if let cgImage = imageCache.image(for: data) {
			Image(decorative: cgImage, scale: 1)
				.resizable()
				.scaledToFit()
				.clipShape(.rect(cornerRadius: 12))
				.accessibilityLabel(Text("Selected image"))
		} else {
			ContentUnavailableView("Image Unavailable", systemImage: "photo")
		}
	}
}
