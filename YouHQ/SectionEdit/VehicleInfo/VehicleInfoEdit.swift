//
//  VehicleInfoEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct VehicleInfoEdit: View {
	let coordinator: SectionEditSheet.ViewModel
	let autoFocus: Bool

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
				currencyCode: $vm.currencyCode,
				url: $vm.url,
				notes: $vm.notes,
				photoPicker: vm.photoPicker,
				autoFocus: autoFocus
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
			)
		)
	)
}
