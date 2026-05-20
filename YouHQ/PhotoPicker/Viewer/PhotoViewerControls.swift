//
//  PhotoViewerControls.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import SwiftUI

/// Toolbar controls for the photo viewer (close, download, reset zoom).
struct PhotoViewerControls: View {
	let onClose: () -> Void
	let onDownload: () -> Void
	let onReset: () -> Void

	var body: some View {
		HStack {
			Button("Close", systemImage: "xmark", action: onClose)
				.labelStyle(.iconOnly)
				.foregroundStyle(.white)

			Spacer()

			Button("Download", systemImage: "square.and.arrow.down", action: onDownload)
				.labelStyle(.iconOnly)
				.foregroundStyle(.white)

			Button("Reset Zoom", systemImage: "arrow.uturn.backward", action: onReset)
				.labelStyle(.iconOnly)
				.foregroundStyle(.white)
		}
		#if !os(visionOS)
			.buttonStyle(.glassProminent)
		#endif
		.tint(.gray)
		.padding()
	}
}
