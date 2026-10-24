//
//  PhotoThumbnailButton.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import SwiftUI

/// Renders the current photo as a tappable thumbnail. Tapping presents the
/// full-screen photo viewer through the overlay-host preference.
struct PhotoThumbnailButton: View {
	let viewModel: PhotoPickerViewModel

	var body: some View {
		if let photoData = viewModel.photoData {
			Button {
				showViewer(for: photoData)
			} label: {
				PhotoThumbnail(data: photoData)
					.id(viewModel.photoRevision)
			}
			.buttonStyle(.plain)
		}
	}

	private func showViewer(for photoData: Data) {
		withAnimation {
			viewModel.viewerPayload = PhotoViewerPayload(data: photoData)
		}
	}
}
