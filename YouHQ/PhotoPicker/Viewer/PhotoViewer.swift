//
//  PhotoViewer.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import SwiftUI
import UniformTypeIdentifiers

/// Full-screen photo viewer with zoom, pan, and download capabilities.
struct PhotoViewer: View {
	let data: Data
	let onClose: (() -> Void)?

	@Environment(\.dismiss) private var dismiss
	@State private var zoomScale: CGFloat = 1
	@State private var lastZoomScale: CGFloat = 1
	@State private var panOffset: CGSize = .zero
	@State private var lastPanOffset: CGSize = .zero
	@State private var isShowingDownloadOptions = false
	@State private var isExportingFile = false
	@State private var downloadErrorMessage: String?
	@State private var isShowingSaveSuccess = false

	var body: some View {
		NavigationStack {
			ZStack {
				ZoomablePhoto(
					data: data,
					zoomScale: $zoomScale,
					lastZoomScale: $lastZoomScale,
					panOffset: $panOffset,
					lastPanOffset: $lastPanOffset
				)
				.frame(maxWidth: .infinity, maxHeight: .infinity)

				VStack {
					PhotoViewerControls(
						onClose: handleClose,
						onDownload: { isShowingDownloadOptions = true },
						onReset: resetZoomAndPan
					)
					#if os(macOS)
						.padding(.top, 64)
						.padding(.horizontal, 48)
					#endif
					Spacer()
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
		.confirmationDialog(
			"Download Image",
			isPresented: $isShowingDownloadOptions
		) {
			Button("Save to Photos") {
				Task { await saveToPhotos() }
			}
			Button("Save to Files") {
				isExportingFile = true
			}
		}
		.fileExporter(
			isPresented: $isExportingFile,
			document: ImageDataDocument(data: data),
			contentType: .jpeg,
			defaultFilename: "YouHQ-Image.jpg"
		) { result in
			if case .failure(let error) = result {
				downloadErrorMessage = error.localizedDescription
			}
		}
		.alert(
			"Download Failed",
			isPresented: Binding(
				get: { downloadErrorMessage != nil },
				set: { isPresented in
					if !isPresented {
						downloadErrorMessage = nil
					}
				}
			)
		) {
			Button("OK") {
				downloadErrorMessage = nil
			}
		} message: {
			if let downloadErrorMessage {
				Text(downloadErrorMessage)
			}
		}
		.alert("Success", isPresented: $isShowingSaveSuccess) {
			Button("OK") {}
		} message: {
			Text("Photo saved to your library.")
		}
	}

	// MARK: - Actions

	private func resetZoomAndPan() {
		withAnimation(.snappy) {
			zoomScale = 1
			lastZoomScale = 1
			panOffset = .zero
			lastPanOffset = .zero
		}
	}

	private func handleClose() {
		if let onClose {
			onClose()
		} else {
			dismiss()
		}
	}

	private func saveToPhotos() async {
		let imageSaver = ImageSaver()
		do {
			try await imageSaver.saveToPhotoLibrary(data: data)
			isShowingSaveSuccess = true
		} catch {
			downloadErrorMessage = error.localizedDescription
		}
	}
}
