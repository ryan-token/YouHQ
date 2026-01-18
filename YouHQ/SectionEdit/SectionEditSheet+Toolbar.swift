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
				Button("Cancel") {
					vm.cancel()
					onDismiss()
				}
			}

			if !vm.section.isNew {
				ToolbarItem(placement: .destructiveAction) {
					Button(role: .destructive) {
						isShowingDeleteConfirmation = true
					} label: {
						Image(systemName: "trash")
					}
					.confirmationDialog(
						"Delete \(vm.sectionString)?",
						isPresented: $isShowingDeleteConfirmation,
						titleVisibility: .visible
					) {
						Button("Delete", role: .destructive) {
							vm.delete()
							onDismiss()
						}
						Button("Cancel", role: .cancel) {}
					} message: {
						Text(vm.deleteConfirmationMessage)
					}
				}
			}

			ToolbarItem(placement: .confirmationAction) {
				Button("Save") {
					vm.save()
					onDismiss()
				}
				.disabled(!vm.isValid)
			}
		}
	}
}
