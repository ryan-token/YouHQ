//
//  MaintenanceItemsScreen.swift
//  YouHQ
//
//  Created by Ryan Token on 1/13/26.
//

import SQLiteData
import SwiftUI

struct MaintenanceItemsScreen: View {
	@Environment(PaywallManager.self) private var paywallManager
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
					Text(
						"Add maintenance items to track when things need attention"
					)
				}
			} else {
				if !vm.pastDueItems.isEmpty {
					Section("Past Due") {
						ForEach(vm.pastDueItems) { item in
							MaintenanceItemRow(
								item: item,
								onTap: {
									vm.editMaintenanceItem(item)
								},
								onComplete: {
									vm.showCompleteAlert(for: item)
								}
							)
						}
						.onDelete { indexSet in
							for index in indexSet {
								vm.deleteMaintenanceItem(vm.pastDueItems[index])
							}
						}
					}
				}

				if !vm.upcomingItems.isEmpty {
					Section("Upcoming") {
						ForEach(vm.upcomingItems) { item in
							MaintenanceItemRow(
								item: item,
								onTap: {
									vm.editMaintenanceItem(item)
								},
								onComplete: {
									vm.showCompleteAlert(for: item)
								}
							)
						}
						.onDelete { indexSet in
							for index in indexSet {
								vm.deleteMaintenanceItem(
									vm.upcomingItems[index]
								)
							}
						}
					}
				}

				if !vm.otherItems.isEmpty {
					Section("Scheduled") {
						ForEach(vm.otherItems) { item in
							MaintenanceItemRow(
								item: item,
								onTap: {
									vm.editMaintenanceItem(item)
								},
								onComplete: {
									vm.showCompleteAlert(for: item)
								}
							)
						}
						.onDelete { indexSet in
							for index in indexSet {
								vm.deleteMaintenanceItem(vm.otherItems[index])
							}
						}
					}
				}
			}
		}
		.navigationTitle("Maintenance Items")
		.navigationTitle("Career")
		#if !os(macOS)
			.navigationBarTitleDisplayMode(.inline)
		#endif
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button {
					if paywallManager.hasUnlockedPremium || vm.maintenanceItems.count < Constants.paywallMaintenanceItemsThreshold {
						vm.showAddMaintenanceItemSheet()
					} else {
						paywallManager.isShowingPaywallSheet = true
					}
				} label: {
					Label("Add", systemImage: "plus")
				}
			}
		}
		.task { await vm.loadData() }
		.sheet(isPresented: $vm.isShowingEditSheet) {
			if let itemToEdit = vm.itemToEdit {
				SectionEditSheet(
					section: vm.isNewItem
						? .maintenanceItemDraft : .maintenanceItem(itemToEdit),
					draftUtility: .constant(nil),
					draftInsurancePolicy: .constant(nil),
					draftMaintenanceItem: .constant(itemToEdit),
					draftPaintColor: .constant(nil),
					draftOther: .constant(nil),
					draftJob: .constant(nil),
					draftDevice: .constant(nil),
					draftServiceProvider: .constant(nil),
					draftSubscription: .constant(nil)
				)
			}
		}
		.alert(
			"Mark as Complete",
			isPresented: $vm.isShowingCompleteAlert
		) {
			Button("Cancel", role: .cancel) {}
			Button("Complete") {
				if let itemToComplete = vm.itemToComplete {
					vm.completeMaintenanceItem(itemToComplete)
				}
			}
		} message: {
			if let item = vm.itemToComplete,
				let nextDue = item.calculateNextDueDate(from: Date()) as Date?
			{
				Text(
					"This will mark \"\(item.name)\" as complete and set the next due date to \(nextDue.formatted(date: .abbreviated, time: .omitted))."
				)
			}
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
