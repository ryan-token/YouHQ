//
//  PhotoPickerViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import PhotosUI
import SQLiteData
import SwiftUI

/// Manages photo selection, display, and persistence for entities that support image attachments.
@Observable
final class PhotoPickerViewModel {
	var photoData: Data?
	var photoItem: PhotosPickerItem?
	var viewerPayload: PhotoViewerPayload?

	init(photoData: Data? = nil, photoItem: PhotosPickerItem? = nil) {
		self.photoData = photoData
		self.photoItem = photoItem
		self.viewerPayload = nil
	}

	func handlePhotoItemChange(_ newItem: PhotosPickerItem?) {
		guard let newItem else { return }
		Task {
			if let data = try? await newItem.loadTransferable(type: Data.self) {
				photoData = data
			}
		}
	}

	func clearPhoto() {
		photoData = nil
		photoItem = nil
	}

	func loadExistingPhotoData(
		in database: Database, link: PhotoAssetLink
	)
		throws
	{
		photoData = try link.fetchImageData(in: database)
	}

	func updateAsset(in database: Database, link: PhotoAssetLink) throws {
		try link.updateAsset(in: database, imageData: photoData)
	}
}
