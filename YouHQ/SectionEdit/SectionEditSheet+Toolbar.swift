//
//  SectionEditSheet+Toolbar.swift
//  YouHQ
//
//  Created by Ryan Token on 1/15/26.
//

import SwiftUI

extension SectionEditSheet {
	struct Toolbar: ToolbarContent {
		let vm: SectionEditSheet.ViewModel
		@Binding var isShowingDeleteConfirmation: Bool
		let onDismiss: () -> Void
		// Read only in the `#if os(macOS)` branch of `body` below.
		// periphery:ignore
		@Environment(\.isPhotoViewerVisible) private var isPhotoViewerVisible

		var body: some ToolbarContent {
			#if os(macOS)
				if !isPhotoViewerVisible {
					toolbarItems
				}
			#else
				toolbarItems
			#endif
		}

		@ToolbarContentBuilder
		private var toolbarItems: some ToolbarContent {
			ToolbarItem(placement: .cancellationAction) {
				// The system supplies the standard Cancel label and symbol.
				Button(role: .cancel, action: cancel)
			}

			if !vm.section.isDraft {
				ToolbarItem(placement: .destructiveAction) {
					Button("Delete", systemImage: "trash", role: .destructive, action: requestDelete)
						#if os(macOS)
							// Keep the existing icon-only appearance on macOS.
							.labelStyle(.iconOnly)
						#endif
						.confirmationDialog(
							"Delete \(vm.sectionString)?",
							isPresented: $isShowingDeleteConfirmation,
							titleVisibility: .visible
						) {
							Button("Delete", role: .destructive, action: delete)
							Button("Cancel", role: .cancel) {}
						} message: {
							HQText(vm.deleteConfirmationMessage)
						}
				}
			}

			ToolbarItem(placement: .confirmationAction) {
				Button("Save", systemImage: "checkmark", role: .confirm, action: save)
					#if os(macOS)
						// Keep the existing "Save" text button on macOS.
						.labelStyle(.titleOnly)
					#endif
					.disabled(!vm.isValid)
			}
		}

		private func cancel() {
			vm.cancel()
			onDismiss()
		}

		private func requestDelete() {
			isShowingDeleteConfirmation = true
		}

		private func delete() {
			vm.delete()
			onDismiss()
		}

		private func save() {
			vm.save()
			onDismiss()
		}
	}
}
