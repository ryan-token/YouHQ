//
//  PhotoPickerSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import PhotosUI
import SwiftUI

struct PhotoPickerSection: View {
	let title: String
	@Binding var photoData: Data?
	@Binding var photoItem: PhotosPickerItem?
	@Binding var viewerPayload: PhotoViewerPayload?
	let onPhotoItemChange: (PhotosPickerItem?) -> Void
	let onRemove: () -> Void

	init(
		title: String,
		photoData: Binding<Data?>,
		photoItem: Binding<PhotosPickerItem?>,
		viewerPayload: Binding<PhotoViewerPayload?>,
		onPhotoItemChange: @escaping (PhotosPickerItem?) -> Void,
		onRemove: @escaping () -> Void
	) {
		self.title = title
		self._photoData = photoData
		self._photoItem = photoItem
		self._viewerPayload = viewerPayload
		self.onPhotoItemChange = onPhotoItemChange
		self.onRemove = onRemove
	}

	var body: some View {
		let hasPhoto = photoData != nil
		Section(title) {
			if let photoData {
				Button {
					viewerPayload = PhotoViewerPayload(data: photoData)
				} label: {
					PhotoPreview(data: photoData)
				}
				.buttonStyle(.plain)
			}

			PhotosPicker(selection: $photoItem, matching: .not(.videos)) {
				Label(
					hasPhoto ? "Change Photo" : "Choose Photo",
					systemImage: "photo"
				)
			}

			if photoData != nil {
				Button("Remove Photo", role: .destructive) {
					withAnimation {
						onRemove()
					}
				}
			}
		}
		.onChange(of: photoItem) { _, newItem in
			onPhotoItemChange(newItem)
		}
	}
}
