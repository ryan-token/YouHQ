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

		@ObservationIgnored
		@FetchAll(Utility.none, animation: .default) var utilities: [Utility]

		@ObservationIgnored
		@FetchAll(InsurancePolicy.none, animation: .default) var insurancePolicies: [InsurancePolicy]

		@ObservationIgnored
		@FetchAll(Other.none, animation: .default) var others: [Other]

		let residenceID: UUID
		var backgroundColor: Color = .indigo

		var totalMonthlyCost: Double {
			var total: Double = 0

			// Add residence monthly cost (rent/mortgage)
			if let residenceCost = residence?.monthlyCost {
				total += residenceCost
			}

			// Add utility costs
			for utility in utilities {
				if let utilityCost = utility.approximateMonthlyCost {
					total += utilityCost
				}
			}

			// Add insurance policy costs
			for policy in insurancePolicies {
				if let policyCost = policy.monthlyCost {
					total += policyCost
				}
			}

			// Add other costs
			for other in others {
				if let otherCost = other.monthlyCost {
					total += otherCost
				}
			}

			return total
		}

		init(residence: Residence) {
			self.residenceID = residence.id
		}

		func loadResidenceData() async {
			await loadResidence()
			await loadUtilities()
			await loadInsurancePolicies()
			await loadOthers()
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

		private func loadUtilities() async {
			_ = await withErrorReporting {
				try await $utilities.load(
					Utility.where { $0.residenceID.eq(residenceID) },
					animation: .default
				)
			}
		}

		private func loadInsurancePolicies() async {
			_ = await withErrorReporting {
				try await $insurancePolicies.load(
					InsurancePolicy.where { $0.residenceID.eq(residenceID) },
					animation: .default
				)
			}
		}

		private func loadOthers() async {
			_ = await withErrorReporting {
				try await $others.load(
					Other.where { $0.residenceID.eq(residenceID) },
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
