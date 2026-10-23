//
//  CameraPresentation.swift
//  YouHQ
//
//  Created by Ryan Token on 1/18/26.
//

#if os(iOS)
	import Foundation

	/// What the camera overlay needs to present; compared by `id` so the preference only
	/// changes when a new presentation starts.
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
#endif
