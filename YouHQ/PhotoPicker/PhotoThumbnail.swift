//
//  PhotoThumbnail.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import SwiftUI

/// Decodes its photo once; give it a new identity to show a different one.
struct PhotoThumbnail: View {
	let data: Data

	/// Enough pixels for a full-width form row on a 3x display, at a fraction of a camera
	/// photo's decoded size.
	private static let maxPixelSize = 1600

	@State private var photo = DecodedPhoto.loading

	var body: some View {
		ZStack {
			switch photo {
			case .loading:
				// Holds the photo's shape so the form doesn't jump when the image arrives.
				Color.clear
					.aspectRatio(placeholderAspectRatio, contentMode: .fit)
			case .image(let cgImage):
				Image(decorative: cgImage, scale: 1)
					.resizable()
					.scaledToFit()
					.clipShape(.rect(cornerRadius: 12))
					.accessibilityLabel(Text("Selected image"))
			case .unavailable:
				ContentUnavailableView("Image Unavailable", systemImage: "photo")
			}
		}
		.task {
			photo = await DecodedPhoto.decode(data, maxPixelSize: Self.maxPixelSize)
		}
	}

	private var placeholderAspectRatio: Double {
		guard let size = orientedPixelSize(of: data) else { return 1 }
		return size.width / size.height
	}
}
