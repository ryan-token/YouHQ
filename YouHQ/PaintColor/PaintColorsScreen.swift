//
//  PaintColorsScreen.swift
//  YouHQ
//
//  Created by Ryan Token on 1/20/26.
//

import SQLiteData
import SwiftUI

struct PaintColorsScreen: View {
	@Namespace private var addButtonNamespace
	@State private var vm: ViewModel

	init(residenceID: UUID? = nil, vehicleID: UUID? = nil) {
		_vm = State(wrappedValue: ViewModel(residenceID: residenceID, vehicleID: vehicleID))
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
					HQText(
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
					.matchedTransitionSource(id: paintColor.id.uuidString, in: addButtonNamespace)
				}
				.onDelete { indexSet in
					for index in indexSet {
						vm.deletePaintColor(vm.paintColors[index])
					}
				}
			}
		}
		.navigationTitle("Paint Colors")
		#if !os(macOS)
			.navigationBarTitleDisplayMode(.inline)
		#endif
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				PaywalledButton(
					title: "Add",
					systemImage: "plus",
					currentCount: vm.paintColors.count,
					threshold: Constants.paywallPaintColorsThreshold
				) {
					vm.showAddPaintColorSheet()
				}
				.matchedTransitionSource(id: "addButton", in: addButtonNamespace)
			}
		}
		.task { await vm.loadData() }
		.sheet(isPresented: $vm.isShowingEditSheet) {
			if let draftItem = vm.draftPaintColor {
				SectionEditSheet(
					section: vm.isNewItem ? .paintColorDraft(draftItem) : .paintColor(draftItem)
				)
				#if !os(macOS)
					.navigationTransition(.zoom(sourceID: vm.sheetTransitionSourceID, in: addButtonNamespace))
				#endif
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
