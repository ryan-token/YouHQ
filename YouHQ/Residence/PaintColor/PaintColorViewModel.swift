//
//  PaintColorViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/20/26.
//

import SQLiteData
import SwiftUI

@Observable
class PaintColorViewModel {
	@ObservationIgnored
	@FetchAll(RoomPaintColor.none, animation: .default) var paintColors

	var draftPaintColor: RoomPaintColor?

	func load(for residenceID: UUID) async {
		_ = await withErrorReporting {
			try await $paintColors.load(
				RoomPaintColor
					.where { $0.residenceID.eq(residenceID) }
					.order { $0.room },
				animation: .default
			)
		}
	}

	func createDraft(for residenceID: UUID) -> RoomPaintColor {
		RoomPaintColor(
			id: UUID(),
			residenceID: residenceID,
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
	}
}
