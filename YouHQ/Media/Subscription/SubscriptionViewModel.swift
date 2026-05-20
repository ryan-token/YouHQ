//
//  SubscriptionViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

@Observable
class SubscriptionViewModel {
	@ObservationIgnored
	@Dependency(\.defaultDatabase) private var database

	@ObservationIgnored
	@FetchAll(Subscription.none, animation: .default) var subscriptions

	func load(for profileID: UUID) async {
		_ = await withErrorReporting {
			try await $subscriptions.load(
				Subscription
					.where { $0.profileID.eq(profileID) }
					.order { $0.name },
				animation: .default
			)
		}
	}

	func createDraft(for profileID: UUID) -> Subscription {
		Subscription(
			id: UUID(),
			profileID: profileID
		)
	}

	func delete(_ subscription: Subscription) {
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

	func updateBackgroundColor(_ color: Color, for subscription: Subscription) {
		withErrorReporting {
			try database.write { db in
				try Subscription.find(subscription.id)
					.update { $0.backgroundColor = color.databaseValue }
					.execute(db)
			}

			Analytics.sendSignal(.itemBackgroundColorChanged)
		}
	}
}
