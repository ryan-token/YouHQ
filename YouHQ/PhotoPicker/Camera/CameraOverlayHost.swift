//
//  CameraOverlayHost.swift
//  YouHQ
//
//  Created by Ryan Token on 1/18/26.
//

#if os(iOS)
	import SwiftUI

	// MARK: - Camera Overlay Host
	//
	// Uses SwiftUI preferences to present the camera as a full-screen overlay.
	// This avoids the iOS bug where presenting a sheet from within another sheet
	// causes both sheets to auto-dismiss.

	struct CameraPresentation: Equatable {
		let id: UUID
		let onImageCaptured: (Data) -> Void
		let onDismiss: () -> Void

		static func == (
			lhs: CameraPresentation, rhs: CameraPresentation
		)
			-> Bool
		{
			lhs.id == rhs.id
		}
	}

	struct CameraPresentationPreferenceKey: PreferenceKey {
		static var defaultValue: CameraPresentation?

		static func reduce(
			value: inout CameraPresentation?,
			nextValue: () -> CameraPresentation?
		) {
			value = nextValue() ?? value
		}
	}

	private struct CameraOverlayHost: ViewModifier {
		func body(content: Content) -> some View {
			content
				.overlayPreferenceValue(CameraPresentationPreferenceKey.self) { presentation in
					if let presentation {
						ZStack {
							Color.black
								.ignoresSafeArea()

							CameraPicker(
								onImageCaptured: { imageData in
									presentation.onImageCaptured(imageData)
									presentation.onDismiss()
								},
								onCancel: {
									presentation.onDismiss()
								}
							)
							.ignoresSafeArea()
						}
						.zIndex(1)
						.transition(.opacity)
						.animation(.snappy, value: presentation.id)
					}
				}
		}
	}

	extension View {
		func cameraOverlayHost() -> some View {
			modifier(CameraOverlayHost())
		}
	}
#endif
