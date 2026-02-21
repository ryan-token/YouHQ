//
//  AddVehicleSheet.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

struct AddVehicleSheet: View {
	@Environment(\.dismiss) private var dismiss
	@State private var vm: ViewModel
	@Binding var selectedVehicle: Vehicle?

	init(profileID: UUID, selectedVehicle: Binding<Vehicle?>) {
		_vm = State(wrappedValue: ViewModel(profileID: profileID))
		_selectedVehicle = selectedVehicle
	}

	var body: some View {
		NavigationStack {
			Form {
				// Profile picker section (only shows if >1 profile)
				if vm.profiles.count > 1 {
					ProfilePickerSection(
						profiles: vm.profiles,
						selectedProfileID: $vm.selectedProfileID,
						itemName: "this new vehicle",
						isNewItem: true
					)
				}

				VehicleFormFields(
					type: $vm.type,
					subType: $vm.subType,
					make: $vm.make,
					model: $vm.model,
					year: $vm.year,
					color: $vm.color,
					backgroundColor: $vm.backgroundColor,
					vin: $vm.vin,
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
			.navigationTitle("New Vehicle")
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
						if let newVehicle = vm.save() {
							selectedVehicle = newVehicle
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
	@Previewable @State var selected: Vehicle?
	let _ = prepareDependencies { // swiftlint:disable:this redundant_discardable_let
		try? $0.bootstrapDatabase()
		try? $0.defaultDatabase.seed()
	}
	AddVehicleSheet(
		profileID: Profile.sampleData.id,
		selectedVehicle: $selected
	)
}
