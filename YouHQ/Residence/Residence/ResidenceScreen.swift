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

	var body: some View {
		List {
			if vm.$residences.isLoading, vm.residences.isEmpty {
				ContentUnavailableView {
					Label("No residences", systemImage: "house")
				} description: {
					Button("Add residence") {
						vm.showCreateResidenceSheet()
					}
				}
			} else {
				if vm.residences.count > 1 {
					Section {
						Picker(
							"Selected Home",
							selection: $vm.selectedResidence
						) {
							ForEach(vm.residences) { residence in
								Text(residence.unitOrStreet ?? residence.street).tag(residence)
							}
						}
						.pickerStyle(.menu)
					}
				}

				ResidenceInfo(vm: vm)
			}
		}
		.scrollDismissesKeyboard(.immediately)
		.navigationTitle(vm.selectedResidence?.unitOrStreet ?? "Home")
		.task { await vm.loadResidenceData() }

		.sheet(isPresented: $vm.isShowingEditSheet) {
			if let profileID = vm.profileID {
				ResidenceEdit(
					residence: vm.residenceToEdit,
					profileID: profileID,
					selectedResidence: $vm.selectedResidence
				)
			}
		}


		.toolbar {
			if vm.selectedResidence != nil {
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						vm.showEditResidenceSheet()
					} label: {
						Label("Edit", systemImage: "pencil")
					}
				}
			}

			ToolbarItem(placement: .topBarTrailing) {
				Button {
					vm.showCreateResidenceSheet()
				} label: {
					Label("Add Residence", systemImage: "plus")
				}
			}
		}
	}
}

#Preview {
	let _ = prepareDependencies {
		try! $0.bootstrapDatabase()
		try! $0.defaultDatabase.seed()
	}

	NavigationStack {
		ResidenceScreen()
	}
}
