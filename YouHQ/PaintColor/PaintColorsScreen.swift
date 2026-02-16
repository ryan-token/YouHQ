//
//  PaintColorsScreen.swift
//  YouHQ
//
//  Created by Ryan Token on 1/20/26.
//

import SQLiteData
import SwiftUI

struct PaintColorsScreen: View {
	@Environment(PaywallManager.self) private var paywallManager
	@State private var vm: ViewModel

	init(residenceID: UUID? = nil, vehicleID: UUID? = nil) {
		_vm = State(wrappedValue: ViewModel(residenceID: residenceID, vehicleID: vehicleID))
	}

	var body: some View {
		@Bindable var paywallManager = paywallManager
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
				Button {
					if paywallManager.hasUnlockedPremium || vm.paintColors.count < Constants.paywallPaintColorsThreshold {
						vm.showAddPaintColorSheet()
					} else {
						paywallManager.showPaywall()
					}
				} label: {
					Label("Add", systemImage: "plus")
				}
			}
		}
		.task { await vm.loadData() }
		.sheet(isPresented: $vm.isShowingEditSheet) {
			if let draftItem = vm.draftPaintColor {
				SectionEditSheet(
					section: vm.isNewItem
						? .paintColorDraft : .paintColor(draftItem),
					draftUtility: .constant(nil),
					draftInsurancePolicy: .constant(nil),
					draftMaintenanceItem: .constant(nil),
					draftPaintColor: $vm.draftPaintColor,
					draftOther: .constant(nil),
					draftJob: .constant(nil),
					draftDevice: .constant(nil),
					draftServiceProvider: .constant(nil),
					draftSubscription: .constant(nil)
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
