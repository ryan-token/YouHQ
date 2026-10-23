//
//  MaintenanceItemsScreen.swift
//  YouHQ
//
//  Created by Ryan Token on 1/13/26.
//

import SQLiteData
import SwiftUI

struct MaintenanceItemsScreen: View {
	@Namespace private var addButtonNamespace
	@State private var vm: ViewModel

	init(residenceID: UUID? = nil, vehicleID: UUID? = nil) {
		_vm = State(wrappedValue: ViewModel(residenceID: residenceID, vehicleID: vehicleID))
	}

	var body: some View {
		List {
			if vm.$maintenanceItems.isLoading, vm.maintenanceItems.isEmpty {
				ContentUnavailableView {
					Label(
						"No Maintenance Items",
						systemImage: "wrench.and.screwdriver"
					)
				} description: {
					HQText(
						"Add maintenance items to track when things need attention"
					)
				}
			} else {
				if !vm.pastDueItems.isEmpty {
					ItemsSection(title: "Past Due", items: vm.pastDueItems, vm: vm, namespace: addButtonNamespace)
				}

				if !vm.upcomingItems.isEmpty {
					ItemsSection(title: "Upcoming", items: vm.upcomingItems, vm: vm, namespace: addButtonNamespace)
				}

				if !vm.otherItems.isEmpty {
					ItemsSection(title: "Scheduled", items: vm.otherItems, vm: vm, namespace: addButtonNamespace)
				}
			}
		}
		.navigationTitle("Maintenance Items")
		#if !os(macOS)
			.navigationBarTitleDisplayMode(.inline)
		#endif
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				PaywalledButton(
					title: "Add",
					systemImage: "plus",
					currentCount: vm.maintenanceItems.count,
					threshold: Constants.paywallMaintenanceItemsThreshold
				) {
					vm.showAddMaintenanceItemSheet()
				}
				.matchedTransitionSource(id: "addButton", in: addButtonNamespace)
			}
		}
		.task { await vm.loadData() }
		.sheet(item: $vm.draftMaintenanceItem) { draftItem in
			SectionEditSheet(
				section: vm.isNewItem ? .maintenanceItemDraft(draftItem) : .maintenanceItem(draftItem)
			)
			#if !os(macOS)
				.navigationTransition(.zoom(sourceID: vm.sheetTransitionSourceID, in: addButtonNamespace))
			#endif
		}
		.alert("Mark as Complete", item: $vm.itemToComplete) { item in
			Button("Cancel", role: .cancel) {}
			Button("Complete") {
				vm.completeMaintenanceItem(item)
			}
		} message: { item in
			HQText(vm.completionMessage(for: item))
		}
	}
}

#Preview {
	let _ = prepareDependencies { // swiftlint:disable:this redundant_discardable_let
		try? $0.bootstrapDatabase()
		try? $0.defaultDatabase.seed()
	}

	NavigationStack {
		MaintenanceItemsScreen(residenceID: Residence.sampleData.id)
	}
}
