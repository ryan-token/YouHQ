//
//  ResidenceScreen.swift
//  YouHQ
//
//  Created by Ryan Token on 12/29/25.
//

import SQLiteData
import SwiftUI

struct ResidenceScreen: View {
	@State private var vm = ViewModel()
	@AppStorage("hideCosts") private var hideCosts = false

	var body: some View {
		List {
			Group {
				#if DEBUG
				ProfileIDView(profileID: vm.selectedProfile?.profile.id)
				#endif

				SharingStatus(vm: vm)

				if vm.residences.isEmpty {
					ContentUnavailableView {
						Label("No residences", systemImage: "house")
					} description: {
						Button("Add residence") {
							vm.showCreateResidenceSheet()
						}
					}
					.frame(maxWidth: .infinity, alignment: .center)
				} else {
					#if os(macOS)
						if vm.residences.count > 1 {
							Picker(
								"Choose Home",
								selection: $vm.selectedResidenceID
							) {
								ForEach(vm.residences) { residence in
									Text(
										residence.unitOrStreet
											?? residence.street
									)
									.tag(residence.id.uuidString)
								}
							}
							.labelsHidden()
						}
					#endif

					Toggle(isOn: $hideCosts) {
						Text("Hide Costs")
							.foregroundStyle(.secondary)
							.font(.headline)
					}
					.listRowBackground(Color.clear)
					.listRowSeparator(.hidden)
					#if os(macOS)
						.padding(.vertical, 4)
					#endif

					ResidenceInfo(vm: vm, hideCosts: hideCosts)
						.listRowSeparator(.hidden)
				}
			}
			.listRowBackground(Color.clear)
		}
		.navigationTitle(vm.selectedResidence?.unitOrStreet ?? "Home")
		#if !os(macOS)
			.if(vm.residences.count > 1) {
				$0.navigationBarTitleDisplayMode(.inline)
			}
		#endif
		.toolbar { Toolbar(vm: vm) }
		.navigationDestination(isPresented: $vm.isNavigatingToMaintenanceItems)
		{
			if let residenceIDString = vm.selectedResidenceID,
				let residenceID = UUID(uuidString: residenceIDString)
			{
				MaintenanceItemsScreen(residenceID: residenceID)
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
				SectionEditSheet(section: sectionToEdit)
			}
		}
		#if !os(visionOS)
			.scrollDismissesKeyboard(.immediately)
		#endif
	}
}

#Preview {
	let _ = prepareDependencies {  // swiftlint:disable:this redundant_discardable_let
		try? $0.bootstrapDatabase()
		try? $0.defaultDatabase.seed()
	}

	NavigationStack {
		ResidenceScreen()
		// .preferredColorScheme(.dark)
	}
}
