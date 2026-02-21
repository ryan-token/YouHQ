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
					url: $vm.url,
					notes: $vm.notes,
					photoPicker: vm.photoPicker,
					autoFocus: true
				)
			}
			.task {
				await vm.loadProfiles()
			}

			#if os(macOS)
				.formStyle(.grouped)
				.frame(minWidth: 500, minHeight: 350)
			#else
				.frame(minHeight: 350)
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
					Button("Cancel") {
						dismiss()
					}
				}

				ToolbarItem(placement: .confirmationAction) {
					Button("Save") {
						if let newResidence = vm.save() {
							selectedResidence = newResidence
						}
						dismiss()
					}
					.disabled(!vm.isValid)
				}
			}
		}
		.photoViewerOverlayHost()
		#if os(iOS)
			.cameraOverlayHost()
		#endif
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
