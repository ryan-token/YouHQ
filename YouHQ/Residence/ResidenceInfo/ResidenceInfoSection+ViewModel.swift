//
//  ResidenceInfoSection+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/11/26.
//

import SQLiteData
import SwiftUI

extension ResidenceInfoSection {
	@Observable
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		@ObservationIgnored
		@FetchOne(Residence.none) var residence: Residence?

		let residenceID: UUID
		var backgroundColor: Color = .indigo

		init(residence: Residence) {
			self.residenceID = residence.id
		}

		func loadResidenceData() async {
			await loadResidence()
			setInitialBackgroundColor()
		}

		// MARK: PRIVATE METHODS

		private func loadResidence() async {
			_ = await withErrorReporting {
				try await $residence.load(
					Residence.where { $0.id.eq(residenceID) },
					animation: .default
				)
			}
		}

		private func setInitialBackgroundColor() {
			backgroundColor = Color(
				databaseValue: residence?.backgroundColor ?? "indigo"
			)
		}

		func updateBackgroundColorFromDatabase() {
			backgroundColor = Color(
				databaseValue: residence?.backgroundColor ?? "indigo"
			)
		}

		func updateResidenceBackgroundColor(_ color: Color) {
			withErrorReporting {
				try database.write { db in
					try Residence.find(residenceID)
						.update { $0.backgroundColor = color.databaseValue }
						.execute(db)
				}
			}
		}
	}
}
