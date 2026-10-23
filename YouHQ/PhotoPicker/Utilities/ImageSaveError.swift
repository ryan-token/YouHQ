//
//  ImageSaveError.swift
//  YouHQ
//
//  Created by Ryan Token on 1/18/26.
//

import Foundation

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
