//
//  PaintColorsScreen+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/20/26.
//

import SQLiteData
import SwiftUI

extension PaintColorsScreen {
	@Observable
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) private var database

		@ObservationIgnored
		@FetchAll(PaintColor.none, animation: .default)
		var paintColors

		let residenceID: UUID
		var isShowingEditSheet = false
		var itemToEdit: PaintColor?
		var isNewItem = false

		init(residenceID: UUID) {
			self.residenceID = residenceID
		}

		func loadData() async {
			_ = await withErrorReporting {
				try await $paintColors.load(
					PaintColor
						.where { $0.residenceID.eq(residenceID) }
						.order { $0.room },
					animation: .default
				)
			}
		}

		func showAddPaintColorSheet() {
			// Create a draft paint color in memory (not in database)
			let draftItem = PaintColor(
				id: UUID(),
				residenceID: residenceID,
				vehicleID: nil,
				manufacturer: "",
				colorName: "",
				colorCode: "",
				room: "",
				finish: .eggshell,
				purchaseDate: nil,
				surfaceType: "",
				storePurchasedFrom: "",
				applicationDate: nil,
				backgroundColor: "purple",
				url: "",
				notes: ""
			)
			itemToEdit = draftItem
			isNewItem = true
			isShowingEditSheet = true
		}

		func editPaintColor(_ item: PaintColor) {
			itemToEdit = item
			isNewItem = false
			isShowingEditSheet = true
		}

		func deletePaintColor(_ item: PaintColor) {
			do {
				try database.write { db in
					try PaintColor.find(item.id)
						.delete()
						.execute(db)
				}

				Analytics.sendSignal(.residencePaintColorDeleted)
			} catch {
				Analytics.logError(id: .paintColorDeleteFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}
	}
}
