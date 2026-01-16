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

	var body: some View {
		Group {
			if let image {
				image
					.resizable()
					.scaledToFit()
					.containerRelativeFrame([.horizontal, .vertical], alignment: .center)
					.scaleEffect(zoomScale)
					.offset(panOffset)
					.contentShape(.rect)
					.gesture(magnifyGesture)
					.simultaneousGesture(panGesture)
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
				zoomScale = newScale
			}
			.onEnded { _ in
				lastZoomScale = zoomScale
				if zoomScale <= 1 {
					withAnimation(.snappy) {
						zoomScale = 1
						lastZoomScale = 1
						panOffset = .zero
						lastPanOffset = .zero
					}
				}
			}
	}

	private var panGesture: some Gesture {
		DragGesture()
			.onChanged { value in
				guard zoomScale > 1 else { return }
				panOffset = CGSize(
					width: lastPanOffset.width + value.translation.width,
					height: lastPanOffset.height + value.translation.height
				)
			}
			.onEnded { _ in
				guard zoomScale > 1 else {
					panOffset = .zero
					lastPanOffset = .zero
					return
				}
				lastPanOffset = panOffset
			}
	}
	private var image: Image? {
		guard let cgImage = orientedCGImage(from: data) else { return nil }
		return Image(decorative: cgImage, scale: 1)
	}
}
