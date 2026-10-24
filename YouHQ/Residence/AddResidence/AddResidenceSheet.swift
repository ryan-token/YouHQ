//
//  AddResidenceSheet.swift
//  YouHQ
//
//  Created by Ryan Token on 1/10/26.
//

import SQLiteData
import SwiftUI

struct AddResidenceSheet: View {
	@Environment(\.dismiss) private var dismiss
	@State private var vm: ViewModel
	@Binding var selectedResidence: Residence?

	init(profileID: UUID, selectedResidence: Binding<Residence?>) {
		_vm = State(wrappedValue: ViewModel(profileID: profileID))
		_selectedResidence = selectedResidence
	}

	var body: some View {
		NavigationStack {
			Form {
				// Profile picker section (only shows if >1 profile)
				if vm.profiles.count > 1 {
					ProfilePickerSection(
						profiles: vm.profiles,
						selectedProfileID: $vm.selectedProfileID,
						itemName: "this new residence",
						isNewItem: true
					)
				}

				ResidenceFormFields(
					type: $vm.type,
					isCurrent: $vm.isCurrent,
					street: $vm.street,
					unit: $vm.unit,
					city: $vm.city,
					state: $vm.state,
					zipCode: $vm.zipCode,
					country: $vm.country,
					moveInDate: $vm.moveInDate,
					moveOutDate: $vm.moveOutDate,
					hasMoveOutDate: $vm.hasMoveOutDate,
					costType: $vm.costType,
					monthlyCost: $vm.monthlyCost,
					currencyCode: $vm.currencyCode,
					url: $vm.url,
					notes: $vm.notes,
					photoPicker: vm.photoPicker,
					autoFocus: true
				)
			}

			#if os(macOS)
				.formStyle(.grouped)
				.frame(minWidth: 500, minHeight: 350)
			#endif
			.navigationTitle("New Residence")
			#if !os(macOS)
				.navigationBarTitleDisplayMode(.inline)
			#endif
			#if !os(visionOS)
				.scrollDismissesKeyboard(.immediately)
			#endif
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					// The system supplies the standard Cancel label and symbol.
					Button(role: .cancel, action: dismiss.callAsFunction)
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
		}
		.task {
			await vm.loadProfiles()
		}
		.photoViewerOverlayHost()
		#if os(iOS)
			.cameraOverlayHost()
		#endif
	}

	/// Saves the residence, selects it when it belongs to the profile being viewed, and dismisses.
	private func save() {
		if let newResidence = vm.save(), vm.isSavingToOriginalProfile {
			selectedResidence = newResidence
		}
		dismiss()
	}
}

#Preview {
	@Previewable @State var selected: Residence?
	let _ = prepareDependencies { // swiftlint:disable:this redundant_discardable_let
		try? $0.bootstrapDatabase()
		try? $0.defaultDatabase.seed()
	}
	AddResidenceSheet(
		profileID: Profile.sampleData.id,
		selectedResidence: $selected
	)
}
