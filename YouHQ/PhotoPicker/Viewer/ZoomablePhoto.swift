//
//  ZoomablePhoto.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import SwiftUI

/// A photo view that supports pinch-to-zoom and pan gestures.
/// On macOS, also supports scroll wheel panning and trackpad magnification.
struct ZoomablePhoto: View {
	let data: Data
	@Binding var zoomScale: CGFloat
	@Binding var lastZoomScale: CGFloat
	@Binding var panOffset: CGSize
	@Binding var lastPanOffset: CGSize

	@State private var containerSize: CGSize = .zero
	@State private var imageSize: CGSize?

	#if !os(macOS)
		@GestureState private var dragTranslation: CGSize = .zero
		@GestureState private var magnifyScale: CGFloat = 1
	#endif

	var body: some View {
		Group {
			if let image {
				image
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
						.overlay(scrollWheelPanOverlay)
					#endif
					.onGeometryChange(for: CGSize.self) { proxy in
						proxy.size
					} action: { newValue in
						updateContainerSize(newValue)
					}
					.onAppear {
						configureImageIfNeeded()
					}
			} else {
				ContentUnavailableView(
					"Image Unavailable",
					systemImage: "photo"
				)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
	}

	// MARK: - Image

	private var image: Image? {
		guard let cgImage = orientedCGImage(from: data) else { return nil }
		return Image(decorative: cgImage, scale: 1)
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
		private var scrollWheelPanOverlay: some View {
			ScrollWheelPanView(
				isScrollEnabled: zoomScale > 1,
				onScroll: { delta in
					let proposed = CGSize(
						width: panOffset.width + delta.width,
						height: panOffset.height + delta.height
					)
					applyClampedPan(proposed)
				},
				onMagnifyBegan: {
					lastZoomScale = zoomScale
				},
				onMagnifyChanged: { magnification in
					let newScale = min(
						max(1, lastZoomScale * (1 + magnification)),
						6
					)
					updateZoomScale(newScale)
				},
				onMagnifyEnded: {
					finishZoom()
				}
			)
		}
	#endif

	// MARK: - Scale and Offset

	private var currentScale: CGFloat {
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

	private func configureImageIfNeeded() {
		guard imageSize == nil else { return }
		imageSize = resolvedImageSize()
		updatePanBounds()
		applyClampedPan(panOffset)
	}

	private func resolvedImageSize() -> CGSize? {
		guard let cgImage = orientedCGImage(from: data) else { return nil }
		return CGSize(width: cgImage.width, height: cgImage.height)
	}

	private func updateContainerSize(_ newValue: CGSize) {
		guard containerSize != newValue else { return }
		containerSize = newValue
		updatePanBounds()
		applyClampedPan(panOffset)
	}

	private func updateZoomScale(_ newScale: CGFloat) {
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

	private func clampedOffset(_ offset: CGSize, scale: CGFloat) -> CGSize {
		guard scale > 1 else { return .zero }
		let maxOffset = maxPanOffset(for: scale)
		return CGSize(
			width: min(max(offset.width, -maxOffset.width), maxOffset.width),
			height: min(max(offset.height, -maxOffset.height), maxOffset.height)
		)
	}

	private func maxPanOffset(for scale: CGFloat) -> CGSize {
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
