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
			List {
				Section("Basic Info") {
					Picker("Type", selection: $vm.type) {
						ForEach(ResidenceType.allCases, id: \.self) { type in
							Text(type.rawValue).tag(type)
						}
					}
					
					Toggle("Current Residence", isOn: $vm.isCurrent)
				}
				
				Section("Address") {
					TextField("Street", text: $vm.street)
					TextField("Unit", text: $vm.unit)
					TextField("City", text: $vm.city)
					TextField("State", text: $vm.state)
					TextField("ZIP Code", text: $vm.zipCode)
					TextField("Country", text: $vm.country)
				}
				
				Section("Dates") {
					DatePicker(
						"Move-In Date",
						selection: Binding(
							get: { vm.moveInDate ?? Date() },
							set: { vm.moveInDate = $0 }
						),
						displayedComponents: .date
					)
					
					Toggle("Has Move-Out Date", isOn: $vm.hasMoveOutDate)
					
					if vm.hasMoveOutDate {
						DatePicker(
							"Move-Out Date",
							selection: Binding(
								get: { vm.moveOutDate ?? Date() },
								set: { vm.moveOutDate = $0 }
							),
							displayedComponents: .date
						)
					}
				}
				
				Section("Cost") {
					Picker("Cost Type", selection: $vm.costType) {
						ForEach(CostType.allCases, id: \.self) { type in
							Text(type.rawValue).tag(type)
						}
					}
					
				TextField(
					"Monthly Cost",
					value: $vm.monthlyCost,
					format: .currency(code: "USD")
				)
				#if !os(macOS)
					.keyboardType(.decimalPad)
				#endif
				}
			}
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
	}
}

extension AddResidenceSheet {
	@Observable
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database
		
		let profileID: UUID
		var type: ResidenceType = .apartment
		var isCurrent: Bool = true
		var street: String = ""
		var unit: String = ""
		var city: String = ""
		var state: String = ""
		var zipCode: String = ""
		var country: String = "USA"
		var moveInDate: Date?
		var moveOutDate: Date?
		var hasMoveOutDate: Bool = false
		var costType: CostType = .rent
		var monthlyCost: Double?
		
		var isValid: Bool {
			street.trimmingCharacters(in: .whitespaces).isNotEmpty
		}
		
		init(profileID: UUID) {
			self.profileID = profileID
		}
		
		func save() -> Residence? {
			var savedResidence: Residence?
			withErrorReporting {
				try database.write { db in
					let residenceID = UUID()
					try Residence.insert {
						Residence.Draft(
							id: residenceID,
							profileID: profileID,
							type: type,
							street: street,
							unit: unit,
							city: city,
							state: state,
							zipCode: zipCode,
							country: country,
							moveInDate: moveInDate,
							moveOutDate: hasMoveOutDate ? moveOutDate : nil,
							isCurrent: isCurrent,
							monthlyCost: monthlyCost,
							costType: costType,
							url: "",
							notes: ""
						)
					}
					.execute(db)
					savedResidence = try Residence.find(residenceID).fetchOne(db)
				}
			}
			return savedResidence
		}
	}
}

#Preview {
	@Previewable @State var selected: Residence?
	let _ = prepareDependencies {
		try! $0.bootstrapDatabase()
		try! $0.defaultDatabase.seed()
	}
	AddResidenceSheet(
		profileID: Profile.sampleData.id,
		selectedResidence: $selected
	)
}
