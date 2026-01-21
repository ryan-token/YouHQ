//
//  MaintenanceItemsScreen.swift
//  YouHQ
//
//  Created by Ryan Token on 1/13/26.
//

import SQLiteData
import SwiftUI

struct MaintenanceItemsScreen: View {
	@State private var vm: ViewModel
	let residenceID: UUID

	init(residenceID: UUID) {
		self.residenceID = residenceID
		_vm = State(wrappedValue: ViewModel(residenceID: residenceID))
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
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button {
					vm.showAddMaintenanceItemSheet()
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
					draftOther: .constant(nil)
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
