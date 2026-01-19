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
			Button {
				onClose()
			} label: {
				Image(systemName: "xmark")
					.foregroundStyle(.white)
			}

			Spacer()

			Button {
				onDownload()
			} label: {
				Image(systemName: "square.and.arrow.down")
					.foregroundStyle(.white)
			}

			Button {
				onReset()
			} label: {
				Image(systemName: "arrow.uturn.backward")
					.foregroundStyle(.white)
			}
		}
		#if !os(visionOS)
		.buttonStyle(.glassProminent)
		#endif
		.tint(.gray)
		.padding()
	}
}
