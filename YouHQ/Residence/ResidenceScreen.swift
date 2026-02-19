//
//  ResidenceScreen.swift
//  YouHQ
//
//  Created by Ryan Token on 12/29/25.
//

import MapKit
import SQLiteData
import SwiftUI

struct ResidenceScreen: View {
	@AppStorage("hideResidenceCosts") private var hideResidenceCosts = false
	@Dependency(\.defaultSyncEngine) var syncEngine
	@Namespace private var addButtonNamespace
	@State private var vm = ViewModel()

	var body: some View {
		List {
			Group {
				SharingStatus(for: vm.selectedProfile)

				if vm.residences.isEmpty {
					NoResidencesView(
						isSynchronizing: syncEngine.isSynchronizing,
						onAddResidenceTapped: { vm.showCreateResidenceSheet(sourceID: "emptyStateButton") }
					)
				} else {
					MacOSResidencePicker(residences: vm.residences, selectedResidence: $vm.selectedResidence)

					HideCostsToggle(hideCosts: $hideResidenceCosts)

					if vm.hasMappableAddresses {
						ResidenceMap(
							residences: vm.residences,
							selectedResidence: $vm.selectedResidence
						)
					}

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
		.toolbar { Toolbar(vm: vm, namespace: addButtonNamespace) }
		.environment(\.sheetNamespace, addButtonNamespace)
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
		.onChange(of: vm.profiles.count) { oldCount, newCount in
			if oldCount == 0 && newCount > 0 { // so we load the default profile on initial sync
				Task { await vm.loadResidenceData() }
			}
		}
		.onReceive(NotificationCenter.default.publisher(for: .profileDidChange)) { _ in
			Task { await vm.handleProfileChange() }
		}
		.onChange(of: vm.residences) {
			vm.updateSelectedResidence()
		}
		.sheet(isPresented: Binding(
			get: { vm.isShowingAddResidenceSheet && vm.selectedProfile?.profile.id != nil },
			set: { vm.isShowingAddResidenceSheet = $0 }
		)) {
			if let profileID = vm.selectedProfile?.profile.id {
				AddResidenceSheet(
					profileID: profileID,
					selectedResidence: $vm.selectedResidence
				)
				#if !os(macOS)
					.navigationTransition(.zoom(sourceID: vm.sheetTransitionSourceID, in: addButtonNamespace))
				#endif
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
		ResidenceScreen()
		// .preferredColorScheme(.dark)
	}
}
