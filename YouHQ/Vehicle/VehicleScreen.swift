//
//  VehicleScreen.swift
//  YouHQ
//
//  Created by Ryan Token on 12/29/25.
//

import SQLiteData
import SwiftUI

struct VehicleScreen: View {
	@Namespace private var addButtonNamespace
	@State private var vm = ViewModel()
	@AppStorage("hideVehicleCosts") private var hideVehicleCosts = false

	var body: some View {
		List {
			Group {
				SharingStatus(for: vm.selectedProfile)

				Group {
					if vm.vehicles.isEmpty {
						NoVehiclesView(
							onAddVehicleTapped: { vm.showCreateVehicleSheet(sourceID: "emptyStateButton") }
						)
					} else {
						MacOSVehiclePicker(vehicles: vm.vehicles, selectedVehicle: $vm.selectedVehicle)

						HideCostsToggle(hideCosts: $hideVehicleCosts)

						VehicleInfo(vm: vm, hideCosts: hideVehicleCosts)
							.id(vm.selectedVehicle?.id)
					}
				}
				.opacity(vm.hasCompletedInitialLoad ? 1 : 0)
			}
			.listRowSeparator(.hidden)
			.listRowBackground(Color.clear)
		}
		.animation(.default, value: vm.vehicles)
		.navigationTitle(vehicleTitle)
		#if !os(macOS)
			.navigationBarTitleDisplayMode(.inline)
		#endif
		.toolbar { Toolbar(vm: vm, namespace: addButtonNamespace) }
		.environment(\.sheetNamespace, addButtonNamespace)
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
		.reloadOnProfileChange(
			profileCount: vm.profiles.count,
			initialLoad: vm.loadVehicleData,
			onProfileChanged: vm.handleProfileChange
		)
		.onChange(of: vm.vehicles) {
			vm.updateSelectedVehicle()
		}
		.sheet(isPresented: $vm.isShowingAddVehicleSheet) {
			if let profileID = vm.selectedProfile?.profile.id {
				AddVehicleSheet(
					profileID: profileID,
					selectedVehicle: $vm.selectedVehicle
				)
				#if !os(macOS)
					.navigationTransition(.zoom(sourceID: vm.sheetTransitionSourceID, in: addButtonNamespace))
				#endif
			}
		}
		.sheet(isPresented: $vm.isShowingSectionEditSheet) {
			if let sectionToEdit = vm.sectionToEdit {
				SectionEditSheet(section: sectionToEdit)
					#if !os(macOS)
						.navigationTransition(.zoom(sourceID: vm.sheetTransitionSourceID, in: addButtonNamespace))
					#endif
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
