//
//  VehicleInfoEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct VehicleInfoEdit: View {
	let coordinator: SectionEditSheet.ViewModel
	var focusedField: FocusState<Bool>.Binding

	var body: some View {
		if let vehicleVM = coordinator.vehicleViewModel {
			@Bindable var vm = vehicleVM
			VehicleFormFields(
				type: $vm.vehicleType,
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
				focusedField: focusedField
			)
		}
	}
}

#Preview("Vehicle Info") {
	SectionEditSheet(
		section: .vehicleInfo(
			Vehicle(
				id: UUID(),
				profileID: UUID(),
				type: .car,
				subType: .gas,
				make: "Toyota",
				model: "Camry",
				year: "2023",
				color: nil,
				vin: nil,
				monthlyCost: nil,
				costType: .owned,
				backgroundColor: "teal",
				url: "",
				notes: ""
			)),
		draftUtility: .constant(nil),
		draftInsurancePolicy: .constant(nil),
		draftMaintenanceItem: .constant(nil),
		draftPaintColor: .constant(nil),
		draftOther: .constant(nil),
		draftJob: .constant(nil),
		draftDevice: .constant(nil),
		draftServiceProvider: .constant(nil),
		draftSubscription: .constant(nil),
		draftBankAccount: .constant(nil),
		draftInvestmentAccount: .constant(nil),
		draftHealthSavingsAccount: .constant(nil)
	)
}
