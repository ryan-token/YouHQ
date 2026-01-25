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

		let residenceID: UUID?
		let vehicleID: UUID?
		var isShowingEditSheet = false
		var itemToEdit: PaintColor?
		var isNewItem = false

		init(residenceID: UUID?, vehicleID: UUID?) {
			self.residenceID = residenceID
			self.vehicleID = vehicleID
		}

		func loadData() async {
			_ = await withErrorReporting {
				if let residenceID {
					try await $paintColors.load(
						PaintColor
							.where { $0.residenceID.eq(residenceID) }
							.order { $0.room },
						animation: .default
					)
				} else if let vehicleID {
					try await $paintColors.load(
						PaintColor
							.where { $0.vehicleID.eq(vehicleID) }
							.order { $0.room },
						animation: .default
					)
				}
			}
		}

		func showAddPaintColorSheet() {
			// Create a draft paint color in memory (not in database)
			let draftItem = PaintColor(
				id: UUID(),
				residenceID: residenceID,
				vehicleID: vehicleID,
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
