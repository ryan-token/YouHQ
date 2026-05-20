//
//  SubscriptionEdit+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

extension SubscriptionEdit {
	@Observable
	final class ViewModel: SectionEditViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		let subscription: Subscription
		let isNew: Bool

		var name: String
		var category: SubscriptionCategory
		var monthlyCost: Double?
		var billingCycle: BillingCycle
		var renewalDate: Date?
		var isActive: Bool
		var url: String
		var notes: String

		// Profile switching support
		@ObservationIgnored
		@FetchAll(ProfileShare.none, animation: .default) var profiles
		var currentProfileID: UUID
		var supportsProfileSwitching: Bool { true }
		var itemNameForProfilePicker: String {
			name.isNotEmpty ? name : "this subscription"
		}

		var title: String {
			isNew ? "Add Subscription" : "Edit Subscription"
		}

		var isValid: Bool {
			true
		}

		var deleteConfirmationMessage: String {
			"Are you sure you want to delete \(name.isEmpty ? "this subscription" : name)?"
		}

		init(subscription: Subscription, isNew: Bool) {
			self.subscription = subscription
			self.isNew = isNew
			self.name = subscription.name
			self.category = subscription.category
			self.monthlyCost = subscription.monthlyCost
			self.billingCycle = subscription.billingCycle
			self.renewalDate = subscription.renewalDate
			self.isActive = subscription.isActive
			self.url = subscription.url
			self.notes = subscription.notes
			self.currentProfileID = subscription.profileID
		}

		func loadProfiles() async {
			_ = await withErrorReporting {
				try await $profiles.load(ProfileShare.allWithSyncMetadata, animation: .default)
			}
		}

		func save() {
			do {
				try database.write { db in
					if isNew {
						// Insert new record
						try Subscription.insert {
							Subscription.Draft(
								id: subscription.id,
								profileID: currentProfileID,
								name: name,
								category: category,
								monthlyCost: monthlyCost,
								billingCycle: billingCycle,
								renewalDate: renewalDate,
								isActive: isActive,
								backgroundColor: subscription.backgroundColor,
								url: url,
								notes: notes
							)
						}
						.execute(db)
						Analytics.sendSignal(.mediaSubscriptionCreated)
					} else {
						// Update existing record
						try Subscription.find(subscription.id)
							.update {
								$0.profileID = currentProfileID
								$0.name = name
								$0.category = category
								$0.monthlyCost = monthlyCost
								$0.billingCycle = billingCycle
								$0.renewalDate = renewalDate
								$0.isActive = isActive
								$0.url = url
								$0.notes = notes
							}
							.execute(db)
					}
				}
			} catch {
				Analytics.logError(id: .subscriptionSaveFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}

		func cancel() {
			// Draft items don't need cleanup since they're never in DB
		}

		func delete() {
			do {
				try database.write { db in
					try Subscription.find(subscription.id)
						.delete()
						.execute(db)
				}
				Analytics.sendSignal(.mediaSubscriptionDeleted)
			} catch {
				Analytics.logError(id: .subscriptionDeleteFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}
	}
}
