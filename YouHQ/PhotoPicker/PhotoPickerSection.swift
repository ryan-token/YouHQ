//
//  PhotoPickerSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import PhotosUI
import SwiftUI

/// A form section that provides photo selection from library and camera (iOS).
/// Shows a thumbnail when a photo is selected, with options to view, change, or remove it.
struct PhotoPickerSection: View {
	let title: String
	@Bindable var viewModel: PhotoPickerViewModel

	#if os(iOS)
		@State private var cameraPresentation: CameraPresentation?
	#endif

	private var hasPhoto: Bool {
		viewModel.photoData != nil
	}

	var body: some View {
		Section(title) {
			thumbnailButton
			libraryPicker
			#if os(iOS)
				cameraButton
			#endif
			removeButton
		}
		#if os(iOS)
			.preference(
				key: CameraPresentationPreferenceKey.self,
				value: cameraPresentation
			)
		#endif
		.preference(
			key: PhotoViewerPresentationPreferenceKey.self,
			value: photoViewerPresentation
		)
		.onChange(of: viewModel.photoItem) { _, newItem in
			viewModel.handlePhotoItemChange(newItem)
		}
	}

	// MARK: - Subviews

	@ViewBuilder
	private var thumbnailButton: some View {
		if let photoData = viewModel.photoData {
			Button {
				withAnimation {
					viewModel.viewerPayload = PhotoViewerPayload(
						data: photoData
					)
				}
			} label: {
				PhotoThumbnail(data: photoData)
			}
			.buttonStyle(.plain)
		}
	}

	private var libraryPicker: some View {
		let labelText =
			hasPhoto ? "Choose Different Image" : "Choose from Library"
		return PhotosPicker(
			selection: $viewModel.photoItem,
			matching: .not(.videos)
		) {
			Label(labelText, systemImage: "photo.on.rectangle")
		}
	}

	#if os(iOS)
		private var cameraButton: some View {
			Button {
				cameraPresentation = CameraPresentation(
					id: UUID(),
					onImageCaptured: { imageData in
						viewModel.photoData = imageData
					},
					onDismiss: {
						cameraPresentation = nil
					}
				)
			} label: {
				Label("Take Photo", systemImage: "camera")
			}
		}
	#endif

	@ViewBuilder
	private var removeButton: some View {
		if hasPhoto {
			Button("Remove Image", role: .destructive) {
				withAnimation {
					viewModel.clearPhoto()
				}
			}
		}
	}

	// MARK: - Preferences

	private var photoViewerPresentation: PhotoViewerPresentation? {
		viewModel.viewerPayload.map { payload in
			PhotoViewerPresentation(
				payload: payload,
				onClose: {
					withAnimation(.snappy) {
						viewModel.viewerPayload = nil
					}
				}
			)
		}
	}
}
