//
//  MediaTests.swift
//  YouHQTests
//
//  Created by Ryan Token on 2/21/26.
//

import Dependencies
import DependenciesTestSupport
import Foundation
import SQLiteData
import Testing

@testable import YouHQ

extension YouHQTests {
	@Suite("Media")
	struct MediaTests {

		@Suite("Devices")
		struct Devices {
			@Dependency(\.defaultDatabase) var database

			@Test("Load fetches devices for a profile")
			func loadDevices() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Device.Draft(id: UUID(-2), profileID: UUID(-1), type: .computer, brand: "Apple", model: "MacBook Pro")
						Device.Draft(id: UUID(-3), profileID: UUID(-1), type: .phone, brand: "Apple", model: "iPhone 16")
					}
				}

				let vm = DeviceViewModel()
				await vm.load(for: UUID(-1))

				#expect(vm.devices.count == 2)
			}

			@Test("Create draft has correct profile ID")
			func createDraft() {
				let vm = DeviceViewModel()
				let draft = vm.createDraft(for: UUID(-1))

				#expect(draft.profileID == UUID(-1))
				#expect(draft.type == .computer)
			}

			@Test("Delete removes device from database")
			func deleteDevice() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Device.Draft(id: UUID(-2), profileID: UUID(-1), type: .tv, brand: "Samsung")
					}
				}

				let vm = DeviceViewModel()
				await vm.load(for: UUID(-1))
				let first = try #require(vm.devices.first)
				vm.delete(first)

				let remaining = try await database.read { db in try Device.fetchCount(db) }
				#expect(remaining == 0)
			}
		}

		// MARK: - ServiceProviderViewModel Tests

		@Suite("Service providers")
		struct ServiceProviders {
			@Dependency(\.defaultDatabase) var database

			@Test("Load fetches service providers for a profile")
			func loadServiceProviders() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						ServiceProvider.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							providerType: .internet,
							name: "Comcast",
							monthlyCost: 80
						)
					}
				}

				let vm = ServiceProviderViewModel()
				await vm.load(for: UUID(-1))

				#expect(vm.serviceProviders.count == 1)
			}

			@Test("Create draft defaults to cell provider type")
			func createDraft() {
				let vm = ServiceProviderViewModel()
				let draft = vm.createDraft(for: UUID(-1))

				#expect(draft.profileID == UUID(-1))
				#expect(draft.providerType == .cell)
			}

			@Test("Delete removes service provider from database")
			func deleteServiceProvider() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						ServiceProvider.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							providerType: .tv,
							name: "DirecTV"
						)
					}
				}

				let vm = ServiceProviderViewModel()
				await vm.load(for: UUID(-1))
				let first = try #require(vm.serviceProviders.first)
				vm.delete(first)

				let remaining = try await database.read { db in try ServiceProvider.fetchCount(db) }
				#expect(remaining == 0)
			}
		}

		// MARK: - SubscriptionViewModel Tests

		@Suite("Subscriptions")
		struct Subscriptions {
			@Dependency(\.defaultDatabase) var database

			@Test("Load fetches subscriptions for a profile")
			func loadSubscriptions() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Subscription.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							name: "Netflix",
							category: .streaming,
							monthlyCost: 15.99,
							billingCycle: .monthly,
							isActive: true
						)
					}
				}

				let vm = SubscriptionViewModel()
				await vm.load(for: UUID(-1))

				#expect(vm.subscriptions.count == 1)
			}

			@Test("Create draft has correct profile ID")
			func createDraft() {
				let vm = SubscriptionViewModel()
				let draft = vm.createDraft(for: UUID(-1))

				#expect(draft.profileID == UUID(-1))
				#expect(draft.name == "")
			}

			@Test("Delete removes subscription from database")
			func deleteSubscription() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Subscription.Draft(id: UUID(-2), profileID: UUID(-1), name: "Spotify")
					}
				}

				let vm = SubscriptionViewModel()
				await vm.load(for: UUID(-1))
				let first = try #require(vm.subscriptions.first)
				vm.delete(first)

				let remaining = try await database.read { db in try Subscription.fetchCount(db) }
				#expect(remaining == 0)
			}
		}

	}
}
