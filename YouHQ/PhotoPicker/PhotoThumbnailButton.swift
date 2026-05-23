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
	@Bindable var viewModel: PhotoPickerViewModel

	var body: some View {
		if let photoData = viewModel.photoData {
			Button {
				withAnimation {
					viewModel.viewerPayload = PhotoViewerPayload(data: photoData)
				}
			} label: {
				PhotoThumbnail(data: photoData)
			}
			.buttonStyle(.plain)
		}
	}
}
