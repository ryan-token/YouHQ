//
//  PaintColorEdit+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/20/26.
//

import SQLiteData
import SwiftUI

extension PaintColorEdit {
	@Observable
	final class ViewModel: SectionEditViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		let paintColor: PaintColor
		let isNew: Bool

		var manufacturer: String
		var colorName: String
		var colorCode: String
		var room: String
		var finish: PaintFinish
		var purchaseDate: Date?
		var surfaceType: String
		var storePurchasedFrom: String
		var applicationDate: Date?
		var backgroundColor: Color
		var url: String
		var notes: String

		var title: String {
			isNew ? "Add Paint Color" : "Edit Paint Color"
		}

		var isValid: Bool {
			true
		}

		var deleteConfirmationMessage: String {
			let roomText = room.isNotEmpty ? room : "this paint color"
			return "Are you sure you want to delete \(roomText)?"
		}

		init(paintColor: PaintColor, isNew: Bool) {
			self.paintColor = paintColor
			self.isNew = isNew
			self.manufacturer = paintColor.manufacturer
			self.colorName = paintColor.colorName
			self.colorCode = paintColor.colorCode
			self.room = paintColor.room
			self.finish = paintColor.finish
			self.purchaseDate = paintColor.purchaseDate
			self.surfaceType = paintColor.surfaceType
			self.storePurchasedFrom = paintColor.storePurchasedFrom
			self.applicationDate = paintColor.applicationDate
			self.backgroundColor = Color(databaseValue: paintColor.backgroundColor)
			self.url = paintColor.url
			self.notes = paintColor.notes
		}

		func save() {
			do {
				try database.write { db in
					if isNew {
						// Insert new record
						try PaintColor.insert {
							PaintColor.Draft(
								id: paintColor.id,
								residenceID: paintColor.residenceID,
								vehicleID: paintColor.vehicleID,
								manufacturer: manufacturer,
								colorName: colorName,
								colorCode: colorCode,
								room: room,
								finish: finish,
								purchaseDate: purchaseDate,
								surfaceType: surfaceType,
								storePurchasedFrom: storePurchasedFrom,
								applicationDate: applicationDate,
								backgroundColor: backgroundColor.databaseValue,
								url: url,
								notes: notes
							)
						}
						.execute(db)
						Analytics.sendSignal(.residencePaintColorCreated)
					} else {
						// Update existing record
						try PaintColor.find(paintColor.id)
							.update {
								$0.manufacturer = manufacturer
								$0.colorName = colorName
								$0.colorCode = colorCode
								$0.room = room
								$0.finish = finish
								$0.purchaseDate = purchaseDate
								$0.surfaceType = surfaceType
								$0.storePurchasedFrom = storePurchasedFrom
								$0.applicationDate = applicationDate
								$0.backgroundColor = backgroundColor.databaseValue
								$0.url = url
								$0.notes = notes
							}
							.execute(db)
					}
				}
			} catch {
				Analytics.logError(id: .paintColorSaveFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}

		func cancel() {
			// Draft items don't need cleanup since they're never in DB
		}

		func delete() {
			do {
				try database.write { db in
					try PaintColor.find(paintColor.id)
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
