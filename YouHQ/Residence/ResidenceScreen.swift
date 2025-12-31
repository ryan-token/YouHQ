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
						vm.createResidenceButtonTapped()
					}
				}
			} else {
				ForEach(vm.residences) { residence in
					Text(residence.street)
				}
				.onDelete { offsets in
					vm.deleteResidences(at: offsets)
				}
			}
		}
		.navigationTitle("Home")
		.task { await vm.onAppear() }

		.alert("Create new residence", isPresented: $vm.isNewResidenceAlertPresented) {
			TextField("Address", text: $vm.newResidenceAddress)
			Button("Save") { vm.createResidence() }
			Button(role: .cancel) {}
		}

		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					vm.createResidenceButtonTapped()
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
