//
//  CameraPicker.swift
//  YouHQ
//
//  Created by Ryan Token on 1/18/26.
//

#if os(iOS)
	import SwiftUI
	import UIKit

	struct CameraPicker: UIViewControllerRepresentable {
		let onImageCaptured: (Data) -> Void
		let onCancel: () -> Void

		func makeUIViewController(context: Context) -> UIImagePickerController {
			let picker = UIImagePickerController()
			picker.sourceType = .camera
			picker.delegate = context.coordinator
			return picker
		}

		func updateUIViewController(
			_ uiViewController: UIImagePickerController,
			context: Context
		) {}

		func makeCoordinator() -> Coordinator {
			Coordinator(parent: self)
		}

		final class Coordinator: NSObject, UIImagePickerControllerDelegate,
			UINavigationControllerDelegate
		{
			let parent: CameraPicker

			init(parent: CameraPicker) {
				self.parent = parent
			}

			func imagePickerController(
				_ picker: UIImagePickerController,
				didFinishPickingMediaWithInfo info: [UIImagePickerController
					.InfoKey: Any]
			) {
				if let image = info[.originalImage] as? UIImage,
					let imageData = image.jpegData(compressionQuality: 0.9)
				{
					parent.onImageCaptured(imageData)
				}
			}

			func imagePickerControllerDidCancel(
				_ picker: UIImagePickerController
			) {
				parent.onCancel()
			}
		}
	}
#endif
