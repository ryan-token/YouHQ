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

	var body: some View {
		Section(title) {
			PhotoThumbnailButton(viewModel: viewModel)
			PhotoLibraryPickerButton(viewModel: viewModel)
			#if os(iOS)
				PhotoCameraButton(viewModel: viewModel, cameraPresentation: $cameraPresentation)
			#endif
			PhotoRemoveButton(viewModel: viewModel)
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
