//
//  ImageSaver.swift
//  YouHQ
//
//  Created by Ryan Token on 1/18/26.
//

import Photos
import SwiftUI

#if os(iOS) || os(visionOS)
	import UIKit
#elseif os(macOS)
	import AppKit
#endif

/// Saves images to the user's photo library with completion handling.
/// Works across iOS, macOS, and visionOS.
final class ImageSaver {

	/// Saves image data to the photo library.
	/// - Parameter data: The image data to save.
	/// - Throws: An error if saving fails or access is denied.
	func saveToPhotoLibrary(data: Data) async throws {
		let status = await requestPhotoLibraryAccess()
		guard status == .authorized || status == .limited else {
			throw ImageSaveError.accessDenied
		}

		let photoData = data
		try await PHPhotoLibrary.shared().performChanges { @Sendable in
			let request = PHAssetCreationRequest.forAsset()
			request.addResource(with: .photo, data: photoData, options: nil)
		}
	}

	private func requestPhotoLibraryAccess() async -> PHAuthorizationStatus {
		let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
		if status != .notDetermined {
			return status
		}

		return await PHPhotoLibrary.requestAuthorization(for: .addOnly)
	}
}

enum ImageSaveError: LocalizedError {
	case accessDenied
	case invalidImageData
	case saveFailed

	var errorDescription: String? {
		switch self {
		case .accessDenied:
			"Photos access is not allowed for this app."
		case .invalidImageData:
			"The image data could not be read."
		case .saveFailed:
			"Unable to save the image to Photos."
		}
	}
}
