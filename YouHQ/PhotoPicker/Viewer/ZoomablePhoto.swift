//
//  ZoomablePhoto.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import SwiftUI

/// A photo view that supports pinch-to-zoom and pan gestures.
/// On macOS, also supports scroll wheel panning and trackpad magnification.
/// Decodes its photo once; give it a new identity to show a different one.
struct ZoomablePhoto: View {
	let data: Data
	@Binding var zoomScale: Double
	@Binding var lastZoomScale: Double
	@Binding var panOffset: CGSize
	@Binding var lastPanOffset: CGSize

	@State private var containerSize: CGSize = .zero
	@State private var photo = DecodedPhoto.loading

	#if !os(macOS)
		@GestureState private var dragTranslation: CGSize = .zero
		@GestureState private var magnifyScale: Double = 1
	#endif

	var body: some View {
		ZStack {
			switch photo {
			case .loading:
				Color.clear
			case .image(let cgImage):
				Image(decorative: cgImage, scale: 1)
					.resizable()
					.scaledToFit()
					.containerRelativeFrame(
						[.horizontal, .vertical],
						alignment: .center
					)
					.scaleEffect(currentScale)
					.offset(displayedOffset)
					.contentShape(.rect)
					#if !os(macOS)
						.gesture(magnifyGesture)
					#endif
					.simultaneousGesture(panGesture)
					#if os(macOS)
						.overlay {
							ScrollWheelPanView(
								isScrollEnabled: zoomScale > 1,
								onScroll: handleScroll,
								onMagnifyBegan: beginMagnify,
								onMagnifyChanged: changeMagnify,
								onMagnifyEnded: finishZoom
							)
						}
					#endif
					.onGeometryChange(for: CGSize.self) { proxy in
						proxy.size
					} action: { newValue in
						updateContainerSize(newValue)
					}
			case .unavailable:
				ContentUnavailableView(
					"Image Unavailable",
					systemImage: "photo"
				)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
		.task {
			photo = await DecodedPhoto.decode(data)
			updatePanBounds()
		}
	}

	// MARK: - Gestures

	#if !os(macOS)
		private var magnifyGesture: some Gesture {
			MagnifyGesture()
				.updating($magnifyScale) { value, state, _ in
					state = value.magnification
				}
				.onEnded { value in
					let newScale = min(
						max(1, lastZoomScale * value.magnification),
						6
					)
					zoomScale = newScale
					updatePanBounds()
					finishZoom()
				}
		}
	#endif

	#if os(macOS)
		private var panGesture: some Gesture {
			DragGesture()
				.onChanged { value in
					guard zoomScale > 1 else { return }
					let proposed = CGSize(
						width: lastPanOffset.width + value.translation.width,
						height: lastPanOffset.height + value.translation.height
					)
					applyClampedPan(proposed)
				}
				.onEnded { _ in
					guard zoomScale > 1 else {
						resetPan()
						return
					}
					applyClampedPan(panOffset)
				}
		}
	#else
		private var panGesture: some Gesture {
			DragGesture()
				.updating($dragTranslation) { value, state, _ in
					state = value.translation
				}
				.onEnded { value in
					guard currentScale > 1 else {
						resetPan()
						return
					}
					let proposed = CGSize(
						width: lastPanOffset.width + value.translation.width,
						height: lastPanOffset.height + value.translation.height
					)
					let clamped = clampedOffset(proposed, scale: currentScale)
					panOffset = clamped
					lastPanOffset = clamped
				}
		}
	#endif

	#if os(macOS)
		private func handleScroll(_ delta: CGSize) {
			let proposed = CGSize(
				width: panOffset.width + delta.width,
				height: panOffset.height + delta.height
			)
			applyClampedPan(proposed)
		}

		private func beginMagnify() {
			lastZoomScale = zoomScale
		}

		private func changeMagnify(_ magnification: CGFloat) {
			let newScale = min(
				max(1, lastZoomScale * (1 + magnification)),
				6
			)
			updateZoomScale(newScale)
		}
	#endif

	// MARK: - Scale and Offset

	private var currentScale: Double {
		#if os(macOS)
			zoomScale
		#else
			min(max(1, lastZoomScale * magnifyScale), 6)
		#endif
	}

	private var displayedOffset: CGSize {
		#if os(macOS)
			clampedOffset(panOffset, scale: zoomScale)
		#else
			let proposed = CGSize(
				width: lastPanOffset.width + dragTranslation.width,
				height: lastPanOffset.height + dragTranslation.height
			)
			return clampedOffset(proposed, scale: currentScale)
		#endif
	}

	// MARK: - Zoom Helpers

	private var imageSize: CGSize? {
		photo.size
	}

	private func updateContainerSize(_ newValue: CGSize) {
		guard containerSize != newValue else { return }
		containerSize = newValue
		updatePanBounds()
		applyClampedPan(panOffset)
	}

	// Called only from the macOS magnify gesture handler above.
	// periphery:ignore
	private func updateZoomScale(_ newScale: Double) {
		zoomScale = newScale
		updatePanBounds()
		if zoomScale <= 1 {
			resetPan()
		} else {
			applyClampedPan(panOffset)
		}
	}

	private func finishZoom() {
		lastZoomScale = zoomScale
		if zoomScale <= 1 {
			resetZoomAndPan(animated: true)
		} else {
			applyClampedPan(panOffset)
		}
	}

	private func resetZoomAndPan(animated: Bool) {
		let reset = {
			zoomScale = 1
			lastZoomScale = 1
			panOffset = .zero
			lastPanOffset = .zero
		}
		if animated {
			withAnimation(.snappy, reset)
		} else {
			reset()
		}
		updatePanBounds()
	}

	// MARK: - Pan Helpers

	private func resetPan() {
		panOffset = .zero
		lastPanOffset = .zero
	}

	private func updatePanBounds() {
		applyClampedPan(panOffset)
	}

	private func applyClampedPan(_ offset: CGSize) {
		let clamped = clampedOffset(offset, scale: zoomScale)
		panOffset = clamped
		lastPanOffset = clamped
	}

	private func clampedOffset(_ offset: CGSize, scale: Double) -> CGSize {
		guard scale > 1 else { return .zero }
		let maxOffset = maxPanOffset(for: scale)
		return CGSize(
			width: min(max(offset.width, -maxOffset.width), maxOffset.width),
			height: min(max(offset.height, -maxOffset.height), maxOffset.height)
		)
	}

	private func maxPanOffset(for scale: Double) -> CGSize {
		guard scale > 1,
			let imageSize,
			containerSize.width > 0,
			containerSize.height > 0
		else {
			return .zero
		}
		let fittedSize = fittedImageSize(
			imageSize: imageSize,
			in: containerSize
		)
		let scaledSize = CGSize(
			width: fittedSize.width * scale,
			height: fittedSize.height * scale
		)
		let maxX = max(0, (scaledSize.width - containerSize.width) / 2)
		let maxY = max(0, (scaledSize.height - containerSize.height) / 2)
		return CGSize(width: maxX, height: maxY)
	}

	private func fittedImageSize(
		imageSize: CGSize, in containerSize: CGSize
	)
		-> CGSize
	{
		guard imageSize.width > 0, imageSize.height > 0 else { return .zero }
		let scale = min(
			containerSize.width / imageSize.width,
			containerSize.height / imageSize.height
		)
		return CGSize(
			width: imageSize.width * scale,
			height: imageSize.height * scale
		)
	}
}
