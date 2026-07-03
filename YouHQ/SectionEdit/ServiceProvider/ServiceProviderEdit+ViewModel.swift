//
//  ServiceProviderEdit+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

extension ServiceProviderEdit {
	@Observable
	final class ViewModel: SectionEditViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		let serviceProvider: ServiceProvider
		let isNew: Bool

		var providerType: ServiceProviderType
		var name: String
		var monthlyCost: Double?
		var currencyCode: String?
		var accountNumber: String
		var url: String
		var notes: String

		// Profile switching support
		@ObservationIgnored
		@FetchAll(ProfileShare.none, animation: .default) var profiles
		var currentProfileID: UUID
		var supportsProfileSwitching: Bool { true }
		var itemNameForProfilePicker: String {
			let displayName = name.isNotEmpty ? "\(name) - \(providerType.rawValue)" : "this service provider"
			return displayName
		}

		var title: String {
			isNew ? "Add Service Provider" : "Edit Service Provider"
		}

		var isValid: Bool {
			true
		}

		var deleteConfirmationMessage: String {
			"Are you sure you want to delete \(name.isEmpty ? "this service provider" : name)?"
		}

		init(serviceProvider: ServiceProvider, isNew: Bool) {
			self.serviceProvider = serviceProvider
			self.isNew = isNew
			self.providerType = serviceProvider.providerType
			self.name = serviceProvider.name
			self.monthlyCost = serviceProvider.monthlyCost
			self.currencyCode = serviceProvider.currencyCode
			self.accountNumber = serviceProvider.accountNumber
			self.url = serviceProvider.url
			self.notes = serviceProvider.notes
			self.currentProfileID = serviceProvider.profileID
		}

		func loadProfiles() async {
			await ProfileShare.reload(into: $profiles)
		}

		func save() {
			do {
				try database.write { db in
					if isNew {
						// Insert new record
						try ServiceProvider.insert {
							ServiceProvider.Draft(
								id: serviceProvider.id,
								profileID: currentProfileID,
								providerType: providerType,
								name: name,
								monthlyCost: monthlyCost,
								currencyCode: currencyCode,
								accountNumber: accountNumber,
								backgroundColor: serviceProvider.backgroundColor,
								url: url,
								notes: notes
							)
						}
						.execute(db)
						Analytics.sendSignal(.mediaServiceProviderCreated)
					} else {
						// Update existing record
						try ServiceProvider.find(serviceProvider.id)
							.update {
								$0.profileID = currentProfileID
								$0.providerType = providerType
								$0.name = name
								$0.monthlyCost = monthlyCost
								$0.currencyCode = currencyCode
								$0.accountNumber = #bind(accountNumber)
								$0.url = url
								$0.notes = notes
							}
							.execute(db)
					}
				}
			} catch {
				Analytics.logError(id: .serviceProviderSaveFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}

		func cancel() {
			// Draft items don't need cleanup since they're never in DB
		}

		func delete() {
			do {
				try database.write { db in
					try ServiceProvider.find(serviceProvider.id)
						.delete()
						.execute(db)
				}
				Analytics.sendSignal(.mediaServiceProviderDeleted)
			} catch {
				Analytics.logError(id: .serviceProviderDeleteFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}
	}
}
