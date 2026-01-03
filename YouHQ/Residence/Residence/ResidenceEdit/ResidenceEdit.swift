//
//  ResidenceEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/2/26.
//

import SQLiteData
import SwiftUI

struct ResidenceEdit: View {
	@Environment(\.dismiss) private var dismiss
	@State private var vm: ViewModel
	@Binding var selectedResidence: Residence?

	init(
		residence: Residence?,
		profileID: UUID,
		selectedResidence: Binding<Residence?>
	) {
		_selectedResidence = selectedResidence
		_vm = State(
			wrappedValue: ViewModel(residence: residence, profileID: profileID)
		)
	}

	var body: some View {
		NavigationStack {
			Form {
				Section("Basic Info") {
					Picker("Type", selection: $vm.type) {
						ForEach(ResidenceType.allCases, id: \.self) { type in
							Text(type.rawValue).tag(type)
						}
					}

					Toggle("Current Residence", isOn: $vm.isCurrent)
				}

				Section("Address") {
					TextField("Street Address", text: $vm.street)
						.textContentType(.streetAddressLine1)
						.textInputAutocapitalization(.words)
					TextField("Unit/Apt (Optional)", text: $vm.unit)
						.textContentType(.streetAddressLine2)
						.textInputAutocapitalization(.words)
					TextField("City", text: $vm.city)
						.textContentType(.addressCity)
						.textInputAutocapitalization(.words)
					TextField("State", text: $vm.state)
						.textContentType(.addressState)
						.textInputAutocapitalization(.characters)
					TextField("ZIP Code", text: $vm.zipCode)
						.textContentType(.postalCode)
						.keyboardType(.numberPad)
					TextField("Country", text: $vm.country)
						.textContentType(.countryName)
						.textInputAutocapitalization(.words)
				}

				Section("Dates") {
					DatePicker(
						"Move In Date (Optional)",
						selection: Binding(
							get: { vm.moveInDate ?? Date() },
							set: { vm.moveInDate = $0 }
						),
						displayedComponents: .date
					)

					DatePicker(
						"Move Out Date (Optional)",
						selection: Binding(
							get: { vm.moveOutDate ?? Date() },
							set: { vm.moveOutDate = $0 }
						),
						displayedComponents: .date
					)
				}

				Section("Cost") {
					Picker("Cost Type", selection: $vm.costType) {
						ForEach(CostType.allCases, id: \.self) { type in
							Text(type.rawValue).tag(type)
						}
					}

					if vm.costType != .owned {
						TextField(
							"Monthly Cost (Optional)",
							value: Binding(
								get: { vm.monthlyCost ?? 0 },
								set: { vm.monthlyCost = $0 }
							),
							format: .currency(code: "USD")
						)
						.keyboardType(.decimalPad)
					}
				}

				Section("Utilities") {
					if vm.utilities.isEmpty {
						Text("No utilities added yet")
							.foregroundStyle(.secondary)
					} else {
						ForEach(vm.utilities) { utility in
							NavigationLink {
								Form {
									UtilityEditRow(utility: utility)
								}
								.navigationTitle(utility.type.rawValue)
								.navigationBarTitleDisplayMode(.inline)
							} label: {
								HStack {
									Text(utility.type.rawValue)
									Spacer()
									if utility.provider.isNotEmpty {
										Text(utility.provider)
											.foregroundStyle(.secondary)
									}
								}
							}
						}
						.onDelete { offsets in
							for index in offsets {
								vm.deleteUtility(vm.utilities[index])
							}
						}
					}

					Menu {
						ForEach(UtilityType.allCases, id: \.self) { type in
							Button(type.rawValue) {
								if let residenceID = vm.residenceID {
									vm.addUtility(
										type: type,
										residenceID: residenceID
									)
								}
							}
						}
						.task {
							if let newResidence = vm.save() {
								print("saving residence")
								vm.residenceID = newResidence.id
								await vm.loadUtilities(for: newResidence.id)
							}
						}
					} label: {
						Label("Add Utility", systemImage: "plus")
					}
				}

				Section("Notes") {
					TextEditor(text: $vm.notes)
						.frame(minHeight: 100)
				}
			}
			.navigationTitle(vm.isEditing ? "Edit Residence" : "New Residence")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
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

							Button("Cancel", role: .cancel) {}
						}
					)
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
		.interactiveDismissDisabled()
	}
}

#Preview("New Residence") {
	@Previewable @State var selected: Residence?
	let _ = prepareDependencies {
		try! $0.bootstrapDatabase()
		try! $0.defaultDatabase.seed()
	}
	ResidenceEdit(
		residence: nil,
		profileID: Profile.sampleData.id,
		selectedResidence: $selected
	)
}

#Preview("Edit Residence") {
	@Previewable @State var selected: Residence? = Residence.sampleData
	let _ = prepareDependencies {
		try! $0.bootstrapDatabase()
		try! $0.defaultDatabase.seed()
	}
	ResidenceEdit(
		residence: Residence.sampleData,
		profileID: Profile.sampleData.id,
		selectedResidence: $selected
	)
}
