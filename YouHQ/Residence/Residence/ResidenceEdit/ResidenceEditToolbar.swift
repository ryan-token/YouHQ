//
//  ResidenceEditToolbar.swift
//  YouHQ
//
//  Created by Ryan Token on 1/3/26.
//

import SwiftUI

struct ResidenceEditToolbar: ToolbarContent {
	@Environment(\.dismiss) private var dismiss
	@Binding var selectedResidence: Residence?
	@Bindable var vm: ResidenceEdit.ViewModel

    var body: some ToolbarContent {
		ToolbarItem(placement: .cancellationAction) {
			Button {
				if vm.isCreating {
					_ = vm.delete()
				}
				dismiss()
			} label: {
				Image(systemName: "xmark")
			}
		}

		if vm.isEditing {
			ToolbarItem(placement: .destructiveAction) {
				Button {
					vm.isShowingDeleteAlert = true
				} label: {
					Image(systemName: "trash")
				}
				.alert(
					"Delete Residence?",
					isPresented: $vm.isShowingDeleteAlert,
					actions: {
						Button(role: .destructive) {
							if vm.delete() {
								selectedResidence = nil
								dismiss()
							} else {
								vm.isShowingDeletionError = true
							}
						} label: {
							Text("Delete")
						}

						Button("Cancel", role: .cancel) {}
					}
				)
				.alert(
					"Error",
					isPresented: $vm.isShowingDeletionError,
					actions: {},
					message: {
						Text(
							"Error deleting residence. Please try again later."
						)
					}
				)
			}
		}

		ToolbarItem(placement: .confirmationAction) {
			Button {
				if let saved = vm.save() {
					selectedResidence = saved
				}
				dismiss()
			} label: {
				Image(systemName: "checkmark")
			}
			.disabled(!vm.isValid)
		}
    }
}
