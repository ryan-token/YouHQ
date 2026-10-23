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
						MacOSVehiclePicker(vehicles: vm.vehicles, selectedVehicleID: $vm.pickerSelectedVehicleID)

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
		.navigationTitle(vm.navigationTitle)
		#if !os(macOS)
			.navigationBarTitleDisplayMode(.inline)
		#endif
		.toolbar { Toolbar(vm: vm, namespace: addButtonNamespace) }
		.environment(\.sheetNamespace, addButtonNamespace)
		.navigationDestination(isPresented: $vm.isNavigatingToMaintenanceItems) {
			if let vehicleID = vm.persistedSelectedVehicleUUID {
				MaintenanceItemsScreen(vehicleID: vehicleID)
			}
		}
		.navigationDestination(isPresented: $vm.isNavigatingToPaintColors) {
			if let vehicleID = vm.persistedSelectedVehicleUUID {
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
		// `vehicles` is delivered by SQLiteData's database observation, so there is no app-owned
		// mutation path to bump a revision in. The key must also catch in-place edits (the
		// selection is refreshed with edited data), which counts or ID arrays would miss. The
		// array is small (capped by the paywall), and `Array ==` returns early when the
		// fetch hasn't delivered a new buffer, so comparing it is cheap.
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
