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
		@Binding var photoViewerPayload: PhotoViewerPayload?
		let onDismiss: () -> Void

		var body: some ToolbarContent {
			ToolbarItem(placement: .cancellationAction) {
				Button("Cancel") {
					vm.cancel()
					photoViewerPayload = nil
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
							photoViewerPayload = nil
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
					photoViewerPayload = nil
					onDismiss()
				}
				.disabled(!vm.isValid)
			}
		}
	}
}
