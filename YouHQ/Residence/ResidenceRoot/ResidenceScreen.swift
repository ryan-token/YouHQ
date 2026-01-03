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
								Text(residence.street).tag(residence)
							}
						}
						.pickerStyle(.menu)
					}
				}

				if let selectedResidence = vm.selectedResidence {
					ResidenceInfo(residence: selectedResidence)
						.id(vm.selectedResidence)
				}
			}
		}
		.navigationTitle(vm.selectedResidence?.unitOrStreet ?? "Home")
		.task { await vm.onAppear() }
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
		.sheet(
			isPresented: $vm.isShowingEditSheet,
			onDismiss: { Task { await vm.onAppear() } }
		) {
			if let profileID = vm.profileID {
				ResidenceEdit(
					residence: vm.residenceToEdit,
					profileID: profileID,
					selectedResidence: $vm.selectedResidence
				)
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
