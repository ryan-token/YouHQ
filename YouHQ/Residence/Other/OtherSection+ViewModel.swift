//
//  OtherSection+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/11/26.
//

import SQLiteData
import SwiftUI

extension OtherSection {
	@Observable
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		@ObservationIgnored
		@FetchOne(Other.none) var other: Other?

		let otherID: UUID
		var backgroundColor: Color = .gray

		var otherNotes: String {
			didSet {
				updateOtherNotes()
			}
		}

		init(other: Other) {
			self.otherID = other.id
			self.otherNotes = ""
		}

		func loadOtherData() async {
			await loadOther()
			setInitialOtherNotes()
			setInitialBackgroundColor()
		}

		// MARK: PRIVATE METHODS

		private func loadOther() async {
			_ = await withErrorReporting {
				try await $other.load(
					Other.where { $0.id.eq(otherID) },
					animation: .default
				)
			}
		}

		private func setInitialOtherNotes() {
			otherNotes = other?.notes ?? ""
		}

		private func setInitialBackgroundColor() {
			backgroundColor = Color(
				databaseValue: other?.backgroundColor ?? "gray"
			)
		}

		private func updateOtherNotes() {
			withErrorReporting {
				try database.write { db in
					try Other.find(otherID)
						.update { $0.notes = otherNotes }
						.execute(db)
				}
			}
		}

		func updateOtherBackgroundColor(_ color: Color) {
			withErrorReporting {
				try database.write { db in
					try Other.find(otherID)
						.update { $0.backgroundColor = color.databaseValue }
						.execute(db)
				}
			}
		}
	}
}
