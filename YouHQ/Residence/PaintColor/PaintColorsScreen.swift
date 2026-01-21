//
//  PaintColorsScreen.swift
//  YouHQ
//
//  Created by Ryan Token on 1/20/26.
//

import SQLiteData
import SwiftUI

struct PaintColorsScreen: View {
	@State private var vm: ViewModel
	let residenceID: UUID

	init(residenceID: UUID) {
		self.residenceID = residenceID
		_vm = State(wrappedValue: ViewModel(residenceID: residenceID))
	}

	var body: some View {
		List {
			if vm.$paintColors.isLoading, vm.paintColors.isEmpty {
				ContentUnavailableView {
					Label(
						"No Paint Colors",
						systemImage: "paintbrush"
					)
				} description: {
					Text(
						"Add paint colors to track what's painted in each room"
					)
				}
			} else {
				ForEach(vm.paintColors) { paintColor in
					PaintColorRow(
						paintColor: paintColor,
						onTap: {
							vm.editPaintColor(paintColor)
						}
					)
				}
				.onDelete { indexSet in
					for index in indexSet {
						vm.deletePaintColor(vm.paintColors[index])
					}
				}
			}
		}
		.navigationTitle("Paint Colors")
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button {
					vm.showAddPaintColorSheet()
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
						? .paintColorDraft : .paintColor(itemToEdit),
					draftUtility: .constant(nil),
					draftInsurancePolicy: .constant(nil),
					draftMaintenanceItem: .constant(nil),
					draftPaintColor: .constant(itemToEdit),
					draftOther: .constant(nil)
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
		PaintColorsScreen(residenceID: Residence.sampleData.id)
	}
}
