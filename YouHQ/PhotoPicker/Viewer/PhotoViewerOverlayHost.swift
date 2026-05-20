//
//  PhotoViewerOverlayHost.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import SwiftUI

// MARK: - Photo Viewer Overlay Host
//
// Uses SwiftUI preferences to present the photo viewer as a full-screen overlay.
// This avoids the iOS bug where presenting a sheet from within another sheet
// causes both sheets to auto-dismiss.

struct PhotoViewerPresentation {
	let payload: PhotoViewerPayload
	let onClose: () -> Void
}

struct PhotoViewerPresentationPreferenceKey: PreferenceKey {
	static let defaultValue: PhotoViewerPresentation? = nil

	static func reduce(
		value: inout PhotoViewerPresentation?,
		nextValue: () -> PhotoViewerPresentation?
	) {
		value = nextValue() ?? value
	}
}

// MARK: - Environment Value

extension EnvironmentValues {
	/// Set when the photo viewer overlay is visible. Used on macOS to hide the
	/// parent sheet's toolbar buttons.
	@Entry var isPhotoViewerVisible: Bool = false
}

// MARK: - View Modifier

private struct PhotoViewerOverlayHost: ViewModifier {
	@State private var isShowingViewer = false

	func body(content: Content) -> some View {
		content
			.environment(\.isPhotoViewerVisible, isShowingViewer)
			.overlayPreferenceValue(PhotoViewerPresentationPreferenceKey.self) { presentation in
				if let presentation {
					ZStack {
						Color.black
							.ignoresSafeArea()

						PhotoViewer(
							data: presentation.payload.data,
							onClose: presentation.onClose
						)
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.transition(.opacity)
					}
					.zIndex(1)
					.animation(.snappy, value: presentation.payload.id)
					.onAppear { isShowingViewer = true }
					.onDisappear { isShowingViewer = false }
				}
			}
	}
}

extension View {
	func photoViewerOverlayHost() -> some View {
		modifier(PhotoViewerOverlayHost())
	}
}
