//
//  PhotoThumbnail.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import SwiftUI

struct PhotoThumbnail: View {
	let data: Data

	var body: some View {
		if let image {
			image
				.resizable()
				.scaledToFit()
				.clipShape(.rect(cornerRadius: 12))
				.accessibilityLabel(Text("Selected image"))
		} else {
			ContentUnavailableView("Image Unavailable", systemImage: "photo")
		}
	}

	private var image: Image? {
		guard let cgImage = orientedCGImage(from: data) else { return nil }
		return Image(decorative: cgImage, scale: 1)
	}
}
