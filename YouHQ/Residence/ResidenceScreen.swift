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
			Group {
				if vm.$residences.isLoading, vm.residences.isEmpty {
					ContentUnavailableView {
						Label("No residences", systemImage: "house")
					} description: {
						Button("Add residence") {
							vm.showCreateResidenceSheet()
						}
					}
				} else {
					ResidenceInfo(vm: vm)
						.listRowSeparator(.hidden)
				}
			}
			.listRowBackground(Color.clear)
		}
		.navigationBarTitleDisplayMode(.inline)
		.navigationTitle(vm.selectedResidence?.unitOrStreet ?? "Home")
		.scrollContentBackground(.hidden)
		.task { await vm.loadResidenceData() }
		.onChange(of: vm.selectedResidenceID) {
			Task { await vm.loadResidenceData() }
		}
		.onChange(of: vm.profiles.count) {
			Task { await vm.loadResidenceData() }
		}
		.sheet(isPresented: $vm.isShowingEditSheet) {
			if let profileID = vm.profileID {
				ResidenceEdit(
					residence: vm.residenceToEdit,
					profileID: profileID,
					selectedResidence: $vm.selectedResidence
				)
			}
		}
		.apply {
			#if !os(visionOS)
				$0.scrollDismissesKeyboard(.immediately)
			#endif
		}
		.toolbar { Toolbar(vm: vm) }
	}
}

#Preview {
	let _ = prepareDependencies {
		try! $0.bootstrapDatabase()
		try! $0.defaultDatabase.seed()
	}

	NavigationStack {
		ResidenceScreen()
			//.preferredColorScheme(.dark)
	}
}
