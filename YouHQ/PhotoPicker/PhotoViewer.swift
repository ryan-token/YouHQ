//
//  PhotoViewer.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import SwiftUI

struct PhotoViewer: View {
	let data: Data
	@Environment(\.dismiss) private var dismiss
	@State private var zoomScale: CGFloat = 1
	@State private var lastZoomScale: CGFloat = 1
	@State private var panOffset: CGSize = .zero
	@State private var lastPanOffset: CGSize = .zero

	var body: some View {
		NavigationStack {
			ZoomablePhoto(
				data: data,
				zoomScale: $zoomScale,
				lastZoomScale: $lastZoomScale,
				panOffset: $panOffset,
				lastPanOffset: $lastPanOffset
			)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Close") {
						dismiss()
					}
				}
				ToolbarItem(placement: .primaryAction) {
					Button("Reset") {
						withAnimation(.snappy) {
							zoomScale = 1
							lastZoomScale = 1
							panOffset = .zero
							lastPanOffset = .zero
						}
					}
				}
			}
			#if os(macOS)
			.safeAreaInset(edge: .bottom) {
				Color.clear.frame(height: 56)
			}
			#endif
		}
		#if os(macOS)
		.frame(minWidth: 600, minHeight: 450)
		.frame(maxWidth: 900, maxHeight: 700)
		#endif
	}
}

private struct ZoomablePhoto: View {
	let data: Data
	@Binding var zoomScale: CGFloat
	@Binding var lastZoomScale: CGFloat
	@Binding var panOffset: CGSize
	@Binding var lastPanOffset: CGSize
	@State private var containerSize: CGSize = .zero
	@State private var imageSize: CGSize?
	@State private var maxPanOffset: CGSize = .zero
	#if !os(macOS)
	@GestureState private var dragTranslation: CGSize = .zero
	#endif

	var body: some View {
		Group {
			if let image {
				image
					.resizable()
					.scaledToFit()
					.containerRelativeFrame([.horizontal, .vertical], alignment: .center)
					.scaleEffect(zoomScale)
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
				ContentUnavailableView("Photo Unavailable", systemImage: "photo")
					.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
	}

	private var magnifyGesture: some Gesture {
		MagnifyGesture()
			.onChanged { value in
				let newScale = min(max(1, lastZoomScale * value.magnification), 6)
				updateZoomScale(newScale)
			}
			.onEnded { _ in
				finishZoom()
			}
	}

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
				guard zoomScale > 1 else {
					resetPan()
					return
				}
				let proposed = CGSize(
					width: lastPanOffset.width + value.translation.width,
					height: lastPanOffset.height + value.translation.height
				)
				let clamped = clampedOffset(proposed)
				panOffset = clamped
				lastPanOffset = clamped
			}
	}
	#endif

	#if os(macOS)
	private var scrollWheelPanOverlay: some View {
		ScrollWheelPanView(isScrollEnabled: zoomScale > 1, onScroll: { delta in
			let proposed = CGSize(
				width: panOffset.width + delta.width,
				height: panOffset.height + delta.height
			)
			applyClampedPan(proposed)
		}, onMagnifyBegan: {
			lastZoomScale = zoomScale
		}, onMagnifyChanged: { magnification in
			let newScale = min(max(1, lastZoomScale * (1 + magnification)), 6)
			updateZoomScale(newScale)
		}, onMagnifyEnded: {
			finishZoom()
		})
	}
	#endif

	private var image: Image? {
		guard let cgImage = orientedCGImage(from: data) else { return nil }
		return Image(decorative: cgImage, scale: 1)
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

	private func resetPan() {
		panOffset = .zero
		lastPanOffset = .zero
	}

	// MARK: Zoom and pan helpers
	private func resolvedImageSize() -> CGSize? {
		guard let cgImage = orientedCGImage(from: data) else { return nil }
		return CGSize(width: cgImage.width, height: cgImage.height)
	}
	private func configureImageIfNeeded() {
		guard imageSize == nil else { return }
		imageSize = resolvedImageSize()
		updatePanBounds()
		applyClampedPan(panOffset)
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

	private func applyClampedPan(_ offset: CGSize) {
		let clamped = clampedOffset(offset)
		panOffset = clamped
		lastPanOffset = clamped
	}

	private func clampedOffset(_ offset: CGSize) -> CGSize {
		guard zoomScale > 1 else { return .zero }
		let maxX = maxPanOffset.width
		let maxY = maxPanOffset.height
		return CGSize(
			width: min(max(offset.width, -maxX), maxX),
			height: min(max(offset.height, -maxY), maxY)
		)
	}
	private func updatePanBounds() {
		guard zoomScale > 1,
			  let imageSize,
			  containerSize.width > 0,
			  containerSize.height > 0
		else {
			maxPanOffset = .zero
			return
		}
		let fittedSize = fittedImageSize(imageSize: imageSize, in: containerSize)
		let scaledSize = CGSize(width: fittedSize.width * zoomScale, height: fittedSize.height * zoomScale)
		let maxX = max(0, (scaledSize.width - containerSize.width) / 2)
		let maxY = max(0, (scaledSize.height - containerSize.height) / 2)
		maxPanOffset = CGSize(width: maxX, height: maxY)
	}

	private func fittedImageSize(imageSize: CGSize, in containerSize: CGSize) -> CGSize {
		guard imageSize.width > 0, imageSize.height > 0 else { return .zero }
		let scale = min(containerSize.width / imageSize.width, containerSize.height / imageSize.height)
		return CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
	}

	private var displayedOffset: CGSize {
		#if os(macOS)
		clampedOffset(panOffset)
		#else
		let proposed = CGSize(
			width: lastPanOffset.width + dragTranslation.width,
			height: lastPanOffset.height + dragTranslation.height
		)
		return clampedOffset(proposed)
		#endif
	}
}
