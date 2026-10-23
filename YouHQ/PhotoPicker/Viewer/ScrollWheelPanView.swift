#if os(macOS)
	import AppKit
	import SwiftUI

	struct ScrollWheelPanView: NSViewRepresentable {
		let isScrollEnabled: Bool
		let onScroll: (CGSize) -> Void
		let onMagnifyBegan: () -> Void
		let onMagnifyChanged: (CGFloat) -> Void
		let onMagnifyEnded: () -> Void

		func makeNSView(context: Context) -> ScrollCaptureView {
			let view = ScrollCaptureView()
			view.onScroll = onScroll
			view.onMagnifyBegan = onMagnifyBegan
			view.onMagnifyChanged = onMagnifyChanged
			view.onMagnifyEnded = onMagnifyEnded
			return view
		}

		func updateNSView(_ nsView: ScrollCaptureView, context: Context) {
			nsView.isScrollEnabled = isScrollEnabled
			nsView.onScroll = onScroll
			nsView.onMagnifyBegan = onMagnifyBegan
			nsView.onMagnifyChanged = onMagnifyChanged
			nsView.onMagnifyEnded = onMagnifyEnded
		}
	}
#endif
