//
//  SectionEditSheet+Toolbar.swift
//  YouHQ
//
//  Created by Ryan Token on 1/15/26.
//

import SwiftUI

extension SectionEditSheet {
	struct Toolbar: ToolbarContent {
		@Environment(\.dismiss) private var dismiss
		let vm: SectionEditSheet.ViewModel
		@Binding var isShowingDeleteConfirmation: Bool

		var body: some ToolbarContent {
			ToolbarItem(placement: .cancellationAction) {
				Button("Cancel") {
					vm.cancel()
					dismiss()
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
							dismiss()
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
					dismiss()
				}
				.disabled(!vm.isValid)
			}
		}
	}
}
