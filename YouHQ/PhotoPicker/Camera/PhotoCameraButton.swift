//
//  PhotoCameraButton.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

#if os(iOS)
	import SwiftUI

	/// Launches the camera UI by writing into the binding that controls the
	/// overlay-host preference key.
	struct PhotoCameraButton: View {
		@Bindable var viewModel: PhotoPickerViewModel
		@Binding var cameraPresentation: CameraPresentation?

		var body: some View {
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
	}
#endif
