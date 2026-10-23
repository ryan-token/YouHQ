#if os(macOS)
	import AppKit

	final class ScrollCaptureView: NSView {
		var onScroll: ((CGSize) -> Void)?
		var onMagnifyBegan: (() -> Void)?
		var onMagnifyChanged: ((CGFloat) -> Void)?
		var onMagnifyEnded: (() -> Void)?
		var isScrollEnabled: Bool = true

		override init(frame frameRect: NSRect) {
			super.init(frame: frameRect)
			setupMagnifyRecognizer()
		}

		required init?(coder: NSCoder) {
			super.init(coder: coder)
			setupMagnifyRecognizer()
		}

		private func setupMagnifyRecognizer() {
			let recognizer = NSMagnificationGestureRecognizer(
				target: self,
				action: #selector(handleMagnify(_:))
			)
			addGestureRecognizer(recognizer)
		}

		override func scrollWheel(with event: NSEvent) {
			guard isScrollEnabled else { return }
			let delta = CGSize(
				width: event.scrollingDeltaX,
				height: event.scrollingDeltaY
			)
			onScroll?(delta)
		}

		@objc private func handleMagnify(
			_ recognizer: NSMagnificationGestureRecognizer
		) {
			switch recognizer.state {
			case .began:
				onMagnifyBegan?()
				onMagnifyChanged?(recognizer.magnification)
			case .changed:
				onMagnifyChanged?(recognizer.magnification)
			case .ended, .cancelled, .failed:
				onMagnifyEnded?()
			default:
				break
			}
		}
	}
#endif
