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
	@FetchAll(PaintColor.none, animation: .default) var paintColors

	func load(for residenceID: UUID) async {
		_ = await withErrorReporting {
			try await $paintColors.load(
				PaintColor
					.where { $0.residenceID.eq(residenceID) }
					.order { $0.room },
				animation: .default
			)
		}
	}

	func loadVehicle(for vehicleID: UUID) async {
		_ = await withErrorReporting {
			try await $paintColors.load(
				PaintColor
					.where { $0.vehicleID.eq(vehicleID) }
					.order { $0.room },
				animation: .default
			)
		}
	}

	func createDraft(for residenceID: UUID) -> PaintColor {
		PaintColor(
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
	}

	func createVehicleDraft(for vehicleID: UUID) -> PaintColor {
		PaintColor(
			id: UUID(),
			residenceID: nil,
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
	}
}
