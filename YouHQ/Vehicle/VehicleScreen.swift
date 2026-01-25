//
//  VehicleScreen.swift
//  YouHQ
//
//  Created by Ryan Token on 12/29/25.
//

import SQLiteData
import SwiftUI

struct VehicleScreen: View {
	@State private var vm = ViewModel()
	@AppStorage("hideVehicleCosts") private var hideVehicleCosts = false

	var body: some View {
		List {
			Group {
				if vm.vehicles.isEmpty {
					NoVehiclesView(onAddVehicleTapped: vm.showCreateVehicleSheet)
				} else {
					MacOSVehiclePicker(vehicles: vm.vehicles, selectedVehicle: $vm.selectedVehicle)

					HideCostsToggle(hideCosts: $hideVehicleCosts)

					VehicleInfo(vm: vm, hideCosts: hideVehicleCosts)
						.id(vm.selectedVehicle?.id)
				}
			}
			.listRowSeparator(.hidden)
			.listRowBackground(Color.clear)
		}
		.animation(.default, value: vm.vehicles)
		.navigationTitle(vehicleTitle)
		#if !os(macOS)
			.if(vm.vehicles.count > 1) {
				$0.navigationBarTitleDisplayMode(.inline)
			}
		#endif
		.toolbar { Toolbar(vm: vm) }
		.navigationDestination(isPresented: $vm.isNavigatingToMaintenanceItems) {
			if let vehicleIDString = vm.selectedVehicleID,
				let vehicleID = UUID(uuidString: vehicleIDString)
			{
				MaintenanceItemsScreen(vehicleID: vehicleID)
			}
		}
		.navigationDestination(isPresented: $vm.isNavigatingToPaintColors) {
			if let vehicleIDString = vm.selectedVehicleID,
				let vehicleID = UUID(uuidString: vehicleIDString)
			{
				PaintColorsScreen(vehicleID: vehicleID)
			}
		}
		.contentMargins(.top, 0)
		.scrollContentBackground(.hidden)
		.task {
			await vm.loadProfiles()
			await vm.loadVehicleData()
		}
		.onChange(of: vm.profiles.count) {
			Task { await vm.loadVehicleData() }
		}
		.onChange(of: vm.vehicles) {
			vm.updateSelectedVehicle()
		}
		.sheet(isPresented: $vm.isShowingAddVehicleSheet) {
			if let profileID = vm.selectedProfile?.profile.id {
				AddVehicleSheet(
					profileID: profileID,
					selectedVehicle: $vm.selectedVehicle
				)
			}
		}
		.sheet(isPresented: $vm.isShowingSectionEditSheet) {
			if let sectionToEdit = vm.sectionToEdit {
				SectionEditSheet(
					section: sectionToEdit,
					draftInsurancePolicy: $vm.insuranceViewModel
						.draftInsurancePolicy,
					draftMaintenanceItem: $vm.maintenanceViewModel
						.draftMaintenanceItem,
					draftPaintColor: $vm.paintColorViewModel.draftPaintColor,
					draftOther: $vm.otherViewModel.draftOther
				)
			}
		}
		#if !os(visionOS)
			.scrollDismissesKeyboard(.immediately)
		#endif
	}

	private var vehicleTitle: String {
		if let vehicle = vm.selectedVehicle {
			var parts: [String] = []
			if let year = vehicle.year, year.isNotEmpty {
				parts.append(year)
			}
			if vehicle.make.isNotEmpty {
				parts.append(vehicle.make)
			}
			if vehicle.model.isNotEmpty {
				parts.append(vehicle.model)
			}
			return parts.isEmpty ? "Vehicles" : parts.joined(separator: " ")
		}
		return "Vehicles"
	}
}

#Preview {
	let _ = prepareDependencies { // swiftlint:disable:this redundant_discardable_let
		try? $0.bootstrapDatabase()
		try? $0.defaultDatabase.seed()
	}

	NavigationStack {
		VehicleScreen()
		// .preferredColorScheme(.dark)
	}
}
