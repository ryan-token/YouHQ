//
//  ResidenceScreen.swift
//  YouHQ
//
//  Created by Ryan Token on 12/29/25.
//

import SQLiteData
import SwiftUI

struct ResidenceScreen: View {
	@Dependency(\.defaultSyncEngine) var syncEngine
	@State private var vm = ViewModel()
	@AppStorage("hideResidenceCosts") private var hideResidenceCosts = false

	var body: some View {
		List {
			Group {
				#if DEBUG
					AvailableProfilesView(for: vm.profiles)
					SelectedProfileIDView(for: vm.selectedProfile?.profile.id)
				#endif

				SharingStatus(vm: vm)

				if vm.residences.isEmpty {
					NoResidencesView(
						isSynchronizing: syncEngine.isSynchronizing,
						onAddResidenceTapped: vm.showCreateResidenceSheet
					)
				} else {
					MacOSResidencePicker(residences: vm.residences, selectedResidence: $vm.selectedResidence)

					HideCostsToggle(hideCosts: $hideResidenceCosts)

					ResidenceInfo(vm: vm, hideCosts: hideResidenceCosts)
						.id(vm.selectedResidence?.id)
				}
			}
			.listRowSeparator(.hidden)
			.listRowBackground(Color.clear)
		}
		.animation(.default, value: vm.residences)
		.navigationTitle(vm.selectedResidence?.unitOrStreet ?? "Home")
		#if !os(macOS)
			.navigationBarTitleDisplayMode(.inline)
		#endif
		.toolbar { Toolbar(vm: vm) }
		.navigationDestination(isPresented: $vm.isNavigatingToMaintenanceItems) {
			if let residenceIDString = vm.selectedResidenceID,
				let residenceID = UUID(uuidString: residenceIDString)
			{
				MaintenanceItemsScreen(residenceID: residenceID)
			}
		}
		.navigationDestination(isPresented: $vm.isNavigatingToPaintColors) {
			if let residenceIDString = vm.selectedResidenceID,
				let residenceID = UUID(uuidString: residenceIDString)
			{
				PaintColorsScreen(residenceID: residenceID)
			}
		}
		.contentMargins(.top, 0)
		.scrollContentBackground(.hidden)
		.task {
			await vm.loadProfiles()
			await vm.loadResidenceData()
		}
		.onChange(of: vm.profiles.count) {
			Task { await vm.loadResidenceData() }
		}
		.onChange(of: vm.residences) {
			vm.updateSelectedResidence()
		}
		.sheet(isPresented: $vm.isShowingAddResidenceSheet) {
			if let profileID = vm.selectedProfile?.profile.id {
				AddResidenceSheet(
					profileID: profileID,
					selectedResidence: $vm.selectedResidence
				)
			}
		}
		.sheet(isPresented: $vm.isShowingSectionEditSheet) {
			if let sectionToEdit = vm.sectionToEdit {
				SectionEditSheet(
					section: sectionToEdit,
					draftUtility: $vm.utilityViewModel.draftUtility,
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
}

#Preview {
	let _ = prepareDependencies { // swiftlint:disable:this redundant_discardable_let
		try? $0.bootstrapDatabase()
		try? $0.defaultDatabase.seed()
	}

	NavigationStack {
		ResidenceScreen()
		// .preferredColorScheme(.dark)
	}
}
