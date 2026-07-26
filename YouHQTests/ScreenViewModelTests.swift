//
//  ScreenViewModelTests.swift
//  YouHQTests
//
//  Created by Ryan Token on 2/21/26.
//

import Dependencies
import DependenciesTestSupport
import Foundation
import SQLiteData
import Sharing
import SwiftUI
import Testing

@testable import YouHQ

extension YouHQTests {
	@Suite("Screen view models")
	struct ScreenViewModelTests {

		@Suite("CareerScreen")
		struct CareerScreenTests {
			@Dependency(\.defaultDatabase) var database

			@Test("sortedJobs puts current jobs before past jobs")
			func sortedJobsCurrentFirst() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Job.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							company: "Past Corp",
							endDate: Date(timeIntervalSince1970: 500_000),
							isCurrent: false
						)
						Job.Draft(
							id: UUID(-3),
							profileID: UUID(-1),
							company: "Current Inc",
							isCurrent: true
						)
					}
				}

				let vm = CareerScreen.ViewModel()
				vm.setSelectedProfileIDString(UUID(-1).uuidString)
				await vm.jobViewModel.load(for: UUID(-1))

				let sorted = vm.sortedJobs
				#expect(sorted.count == 2)
				#expect(sorted[0].company == "Current Inc")
				#expect(sorted[1].company == "Past Corp")
			}

			@Test("sortedJobs sorts past jobs by end date descending")
			func sortedJobsByEndDate() async throws {
				let earlier = Date(timeIntervalSince1970: 500_000)
				let later = Date(timeIntervalSince1970: 900_000)

				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Job.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							company: "Older Job",
							endDate: earlier,
							isCurrent: false
						)
						Job.Draft(
							id: UUID(-3),
							profileID: UUID(-1),
							company: "Newer Job",
							endDate: later,
							isCurrent: false
						)
					}
				}

				let vm = CareerScreen.ViewModel()
				await vm.jobViewModel.load(for: UUID(-1))

				let sorted = vm.sortedJobs
				#expect(sorted.count == 2)
				#expect(sorted[0].company == "Newer Job")
				#expect(sorted[1].company == "Older Job")
			}

			@Test("sortedJobs prefers end date over no end date for past jobs")
			func sortedJobsEndDateBeforeNoEndDate() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Job.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							company: "No End Date",
							isCurrent: false
						)
						Job.Draft(
							id: UUID(-3),
							profileID: UUID(-1),
							company: "Has End Date",
							endDate: Date(timeIntervalSince1970: 500_000),
							isCurrent: false
						)
					}
				}

				let vm = CareerScreen.ViewModel()
				await vm.jobViewModel.load(for: UUID(-1))

				let sorted = vm.sortedJobs
				#expect(sorted.count == 2)
				#expect(sorted[0].company == "Has End Date")
				#expect(sorted[1].company == "No End Date")
			}

			@Test("sortedJobs falls back to start date when no end dates")
			func sortedJobsByStartDate() async throws {
				let earlier = Date(timeIntervalSince1970: 500_000)
				let later = Date(timeIntervalSince1970: 900_000)

				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Job.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							company: "Earlier Start",
							startDate: earlier,
							isCurrent: false
						)
						Job.Draft(
							id: UUID(-3),
							profileID: UUID(-1),
							company: "Later Start",
							startDate: later,
							isCurrent: false
						)
					}
				}

				let vm = CareerScreen.ViewModel()
				await vm.jobViewModel.load(for: UUID(-1))

				let sorted = vm.sortedJobs
				#expect(sorted.count == 2)
				#expect(sorted[0].company == "Later Start")
				#expect(sorted[1].company == "Earlier Start")
			}

			@Test("sortedJobs falls back to alphabetical when no dates")
			func sortedJobsAlphabetical() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Job.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							company: "Zebra Corp",
							isCurrent: false
						)
						Job.Draft(
							id: UUID(-3),
							profileID: UUID(-1),
							company: "Alpha Inc",
							isCurrent: false
						)
					}
				}

				let vm = CareerScreen.ViewModel()
				await vm.jobViewModel.load(for: UUID(-1))

				let sorted = vm.sortedJobs
				#expect(sorted.count == 2)
				#expect(sorted[0].company == "Alpha Inc")
				#expect(sorted[1].company == "Zebra Corp")
			}

			@Test("careerItemsCount sums jobs and other items")
			func careerItemsCount() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Job.Draft(id: UUID(-2), profileID: UUID(-1), company: "Job 1")
						Job.Draft(id: UUID(-3), profileID: UUID(-1), company: "Job 2")
						Other.Draft(
							id: UUID(-4),
							profileID: UUID(-1),
							category: .career,
							name: "Cert"
						)
					}
				}

				let vm = CareerScreen.ViewModel()
				await vm.jobViewModel.load(for: UUID(-1))
				await vm.otherViewModel.loadCategory(for: .career, profileID: UUID(-1))

				#expect(vm.careerItemsCount == 3)
			}
		}

		// MARK: - MoneyScreen.ViewModel

		@Suite("MoneyScreen")
		struct MoneyScreenTests {
			@Dependency(\.defaultDatabase) var database

			@Test("moneyItemsCount sums all money entity types")
			func moneyItemsCount() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						BankAccount.Draft(id: UUID(-2), profileID: UUID(-1))
						BankAccount.Draft(id: UUID(-3), profileID: UUID(-1))
						InvestmentAccount.Draft(id: UUID(-4), profileID: UUID(-1))
						HealthSavingsAccount.Draft(id: UUID(-5), profileID: UUID(-1))
						InsurancePolicy.Draft(
							id: UUID(-6),
							profileID: UUID(-1),
							type: .health
						)
						Other.Draft(
							id: UUID(-7),
							profileID: UUID(-1),
							category: .money,
							name: "Cash"
						)
					}
				}

				let vm = MoneyScreen.ViewModel()
				await vm.bankAccountViewModel.load(for: UUID(-1))
				await vm.investmentAccountViewModel.load(for: UUID(-1))
				await vm.healthSavingsAccountViewModel.load(for: UUID(-1))

				// Load standalone insurance policies (not tied to residence or vehicle)
				_ = await withErrorReporting {
					try await vm.insuranceViewModel.$insurancePolicies.load(
						InsurancePolicy
							.where {
								$0.profileID.eq(UUID(-1))
									.and($0.residenceID.is(nil))
									.and($0.vehicleID.is(nil))
							}
							.order { $0.type },
						animation: .default
					)
				}

				await vm.otherViewModel.loadCategory(for: .money, profileID: UUID(-1))

				#expect(vm.moneyItemsCount == 6)
			}
		}

		// MARK: - ResidenceScreen.ViewModel

		@Suite("ResidenceScreen")
		struct ResidenceScreenTests {
			@Dependency(\.defaultDatabase) var database

			@Test("residenceItemsCount sums utilities, insurance policies, and others")
			func residenceItemsCount() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						Utility.Draft(id: UUID(-3), residenceID: UUID(-2))
						Utility.Draft(id: UUID(-4), residenceID: UUID(-2))
						InsurancePolicy.Draft(
							id: UUID(-5),
							profileID: UUID(-1),
							residenceID: UUID(-2),
							type: .renters
						)
						Other.Draft(
							id: UUID(-6),
							profileID: UUID(-1),
							residenceID: UUID(-2),
							category: .homes,
							name: "Pool"
						)
					}
				}

				let vm = ResidenceScreen.ViewModel()
				await vm.utilityViewModel.load(for: UUID(-2))
				await vm.insuranceViewModel.load(for: UUID(-2))
				await vm.otherViewModel.loadResidence(for: UUID(-2))

				// 2 utilities + 1 insurance + 1 other = 4
				#expect(vm.residenceItemsCount == 4)
			}

			@Test("hasMappableAddresses returns true when a residence has street and city")
			func hasMappableAddressesTrue() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							street: "123 Main St",
							city: "Springfield"
						)
					}
				}

				let vm = ResidenceScreen.ViewModel()
				// Load residences directly via the @FetchAll property
				_ = await withErrorReporting {
					try await vm.$residences.load(
						Residence
							.where { $0.profileID.eq(UUID(-1)) }
							.order { $0.street },
						animation: .default
					)
				}

				#expect(vm.hasMappableAddresses)
			}

			@Test("hasMappableAddresses returns false when street or city is empty")
			func hasMappableAddressesFalse() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							street: "",
							city: "Springfield"
						)
						Residence.Draft(
							id: UUID(-3),
							profileID: UUID(-1),
							street: "123 Main",
							city: ""
						)
					}
				}

				let vm = ResidenceScreen.ViewModel()
				_ = await withErrorReporting {
					try await vm.$residences.load(
						Residence
							.where { $0.profileID.eq(UUID(-1)) }
							.order { $0.street },
						animation: .default
					)
				}

				#expect(!vm.hasMappableAddresses)
			}
		}

		// MARK: - VehicleScreen.ViewModel

		@Suite("VehicleScreen")
		struct VehicleScreenTests {
			@Dependency(\.defaultDatabase) var database

			@Test("vehicleItemsCount sums insurance policies and others")
			func vehicleItemsCount() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Vehicle.Draft(id: UUID(-2), profileID: UUID(-1), make: "Toyota")
						InsurancePolicy.Draft(
							id: UUID(-3),
							profileID: UUID(-1),
							vehicleID: UUID(-2),
							type: .auto
						)
						InsurancePolicy.Draft(
							id: UUID(-4),
							profileID: UUID(-1),
							vehicleID: UUID(-2),
							type: .auto
						)
						Other.Draft(
							id: UUID(-5),
							profileID: UUID(-1),
							vehicleID: UUID(-2),
							category: .vehicles,
							name: "Dashcam"
						)
					}
				}

				let vm = VehicleScreen.ViewModel()
				await vm.insuranceViewModel.loadVehicle(for: UUID(-2))
				await vm.otherViewModel.loadVehicle(for: UUID(-2))

				// 2 insurance + 1 other = 3
				#expect(vm.vehicleItemsCount == 3)
			}
		}

		// MARK: - MaintenanceItemsScreen.ViewModel

		@Suite("MaintenanceItemsScreen")
		struct MaintenanceItemsScreenTests {
			@Dependency(\.defaultDatabase) var database

			@Test("pastDueItems filters items with due date in the past")
			func pastDueItems() async throws {
				let pastDate = Date(timeIntervalSince1970: 1_000)
				let futureDate = Date(timeIntervalSinceNow: 86400 * 365)

				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1))
						MaintenanceItem.Draft(
							id: UUID(-3),
							residenceID: UUID(-2),
							name: "Past Due Filter",
							dueDate: pastDate
						)
						MaintenanceItem.Draft(
							id: UUID(-4),
							residenceID: UUID(-2),
							name: "Future Item",
							dueDate: futureDate
						)
					}
				}

				let vm = MaintenanceItemsScreen.ViewModel(residenceID: UUID(-2), vehicleID: nil)
				await vm.loadData()

				#expect(vm.pastDueItems.count == 1)
				#expect(vm.pastDueItems[0].name == "Past Due Filter")
			}

			@Test("upcomingItems filters items due within 30 days that are not past due")
			func upcomingItems() async throws {
				let pastDate = Date(timeIntervalSince1970: 1_000)
				let upcomingDate = Date(timeIntervalSinceNow: 86400 * 15) // 15 days from now
				let farFuture = Date(timeIntervalSinceNow: 86400 * 365)

				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1))
						MaintenanceItem.Draft(
							id: UUID(-3),
							residenceID: UUID(-2),
							name: "Past Due",
							dueDate: pastDate
						)
						MaintenanceItem.Draft(
							id: UUID(-4),
							residenceID: UUID(-2),
							name: "Upcoming Filter",
							dueDate: upcomingDate
						)
						MaintenanceItem.Draft(
							id: UUID(-5),
							residenceID: UUID(-2),
							name: "Far Future",
							dueDate: farFuture
						)
					}
				}

				let vm = MaintenanceItemsScreen.ViewModel(residenceID: UUID(-2), vehicleID: nil)
				await vm.loadData()

				#expect(vm.upcomingItems.count == 1)
				#expect(vm.upcomingItems[0].name == "Upcoming Filter")
			}

			@Test("otherItems filters items that are neither past due nor upcoming")
			func otherItems() async throws {
				let pastDate = Date(timeIntervalSince1970: 1_000)
				let upcomingDate = Date(timeIntervalSinceNow: 86400 * 15)
				let farFuture = Date(timeIntervalSinceNow: 86400 * 365)

				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1))
						MaintenanceItem.Draft(
							id: UUID(-3),
							residenceID: UUID(-2),
							name: "Past Due",
							dueDate: pastDate
						)
						MaintenanceItem.Draft(
							id: UUID(-4),
							residenceID: UUID(-2),
							name: "Upcoming",
							dueDate: upcomingDate
						)
						MaintenanceItem.Draft(
							id: UUID(-5),
							residenceID: UUID(-2),
							name: "Far Future Other",
							dueDate: farFuture
						)
						MaintenanceItem.Draft(
							id: UUID(-6),
							residenceID: UUID(-2),
							name: "No Date Other"
						)
					}
				}

				let vm = MaintenanceItemsScreen.ViewModel(residenceID: UUID(-2), vehicleID: nil)
				await vm.loadData()

				#expect(vm.otherItems.count == 2)
				let names = vm.otherItems.map(\.name)
				#expect(names.contains("Far Future Other"))
				#expect(names.contains("No Date Other"))
			}

			@Test("items load for vehicle context")
			func vehicleContext() async throws {
				let pastDate = Date(timeIntervalSince1970: 1_000)

				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Vehicle.Draft(id: UUID(-2), profileID: UUID(-1), make: "Toyota")
						MaintenanceItem.Draft(
							id: UUID(-3),
							vehicleID: UUID(-2),
							name: "Oil Change",
							dueDate: pastDate
						)
					}
				}

				let vm = MaintenanceItemsScreen.ViewModel(residenceID: nil, vehicleID: UUID(-2))
				await vm.loadData()

				#expect(vm.maintenanceItems.count == 1)
				#expect(vm.pastDueItems.count == 1)
				#expect(vm.pastDueItems[0].name == "Oil Change")
			}
		}

		// MARK: - MediaScreen.ViewModel

		@Suite("MediaScreen")
		struct MediaScreenTests {
			@Dependency(\.defaultDatabase) var database

			@Test("totalMonthlyCost sums service provider costs")
			func totalCostServiceProviders() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						ServiceProvider.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							monthlyCost: 60
						)
						ServiceProvider.Draft(
							id: UUID(-3),
							profileID: UUID(-1),
							monthlyCost: 40
						)
					}
				}

				let vm = MediaScreen.ViewModel()
				await vm.serviceProviderViewModel.load(for: UUID(-1))

				#expect(vm.totalMonthlyCost == 100)
			}

			@Test("totalMonthlyCost includes active monthly subscriptions")
			func totalCostActiveMonthly() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Subscription.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							name: "Netflix",
							monthlyCost: 15.99,
							billingCycle: .monthly,
							isActive: true
						)
					}
				}

				let vm = MediaScreen.ViewModel()
				await vm.subscriptionViewModel.load(for: UUID(-1))

				#expect(vm.totalMonthlyCost == 15.99)
			}

			@Test("totalMonthlyCost divides annual subscription by 12")
			func totalCostAnnualDivided() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Subscription.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							name: "iCloud",
							monthlyCost: 120,
							billingCycle: .annual,
							isActive: true
						)
					}
				}

				let vm = MediaScreen.ViewModel()
				await vm.subscriptionViewModel.load(for: UUID(-1))

				#expect(vm.totalMonthlyCost == 10)
			}

			@Test("totalMonthlyCost excludes inactive subscriptions")
			func totalCostExcludesInactive() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Subscription.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							name: "Cancelled Sub",
							monthlyCost: 50,
							billingCycle: .monthly,
							isActive: false
						)
					}
				}

				let vm = MediaScreen.ViewModel()
				await vm.subscriptionViewModel.load(for: UUID(-1))

				#expect(vm.totalMonthlyCost == 0)
			}

			@Test("totalMonthlyCost combines service providers and subscriptions")
			func totalCostCombined() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						ServiceProvider.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							monthlyCost: 70
						)
						Subscription.Draft(
							id: UUID(-3),
							profileID: UUID(-1),
							name: "Spotify",
							monthlyCost: 9.99,
							billingCycle: .monthly,
							isActive: true
						)
						Subscription.Draft(
							id: UUID(-4),
							profileID: UUID(-1),
							name: "Costco",
							monthlyCost: 120,
							billingCycle: .annual,
							isActive: true
						)
					}
				}

				let vm = MediaScreen.ViewModel()
				await vm.serviceProviderViewModel.load(for: UUID(-1))
				await vm.subscriptionViewModel.load(for: UUID(-1))

				// 70 + 9.99 + (120 / 12)
				#expect(vm.totalMonthlyCost == 89.99)
			}

			@Test("totalMonthlyCost skips nil costs")
			func totalCostSkipsNil() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						ServiceProvider.Draft(
							id: UUID(-2),
							profileID: UUID(-1)
						)
						Subscription.Draft(
							id: UUID(-3),
							profileID: UUID(-1),
							name: "No Cost",
							isActive: true
						)
					}
				}

				let vm = MediaScreen.ViewModel()
				await vm.serviceProviderViewModel.load(for: UUID(-1))
				await vm.subscriptionViewModel.load(for: UUID(-1))

				#expect(vm.totalMonthlyCost == 0)
			}

			@Test("mediaItemsCount sums all media entity types")
			func mediaItemsCount() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Device.Draft(id: UUID(-2), profileID: UUID(-1))
						ServiceProvider.Draft(id: UUID(-3), profileID: UUID(-1))
						Subscription.Draft(id: UUID(-4), profileID: UUID(-1), name: "Sub")
						Other.Draft(
							id: UUID(-5),
							profileID: UUID(-1),
							category: .media,
							name: "Extra"
						)
					}
				}

				let vm = MediaScreen.ViewModel()
				await vm.deviceViewModel.load(for: UUID(-1))
				await vm.serviceProviderViewModel.load(for: UUID(-1))
				await vm.subscriptionViewModel.load(for: UUID(-1))
				await vm.otherViewModel.loadCategory(for: .media, profileID: UUID(-1))

				#expect(vm.mediaItemsCount == 4)
			}
		}
	}
}
