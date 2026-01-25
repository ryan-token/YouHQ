//
//  ServiceProviderViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

@Observable
class ServiceProviderViewModel {
	@ObservationIgnored
	@Dependency(\.defaultDatabase) private var database

	@ObservationIgnored
	@FetchAll(ServiceProvider.none, animation: .default) var serviceProviders

	var draftServiceProvider: ServiceProvider?

	func load(for profileID: UUID) async {
		_ = await withErrorReporting {
			try await $serviceProviders.load(
				ServiceProvider
					.where { $0.profileID.eq(profileID) }
					.order { $0.name },
				animation: .default
			)
		}
	}

	func createDraft(for profileID: UUID) -> ServiceProvider {
		ServiceProvider(
			id: UUID(),
			profileID: profileID,
			providerType: .cell
		)
	}

	func delete(_ serviceProvider: ServiceProvider) {
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

	func updateBackgroundColor(_ color: Color, for serviceProvider: ServiceProvider) {
		withErrorReporting {
			try database.write { db in
				try ServiceProvider.find(serviceProvider.id)
					.update { $0.backgroundColor = color.databaseValue }
					.execute(db)
			}

			Analytics.sendSignal(.itemBackgroundColorChanged)
		}
	}
}
