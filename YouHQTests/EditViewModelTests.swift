//
//  EditViewModelTests.swift
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
	@Suite("Edit view models")
	struct EditViewModelTests {

		@Suite("PaintColorEdit")
		struct PaintColorEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("deleteConfirmationMessage uses room when present, falls back when empty")
			func deleteMessage() {
				let withRoom = PaintColor(id: UUID(-1), profileID: nil, residenceID: UUID(-2), vehicleID: nil, room: "Kitchen")
				let withoutRoom = PaintColor(id: UUID(-3), profileID: nil, residenceID: UUID(-2), vehicleID: nil, room: "")
				let vmWith = PaintColorEdit.ViewModel(paintColor: withRoom, isNew: false)
				let vmWithout = PaintColorEdit.ViewModel(paintColor: withoutRoom, isNew: false)

				#expect(vmWith.deleteConfirmationMessage == "Are you sure you want to delete Kitchen?")
				#expect(vmWithout.deleteConfirmationMessage == "Are you sure you want to delete this paint color?")
			}

			@Test("Save inserts new paint color into database")
			func saveInsert() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
					}
				}

				let paintColor = PaintColor(
					id: UUID(0), profileID: nil,
					residenceID: UUID(-2),
					vehicleID: nil,
					manufacturer: "Sherwin-Williams",
					colorName: "Agreeable Gray"
				)
				let vm = PaintColorEdit.ViewModel(paintColor: paintColor, isNew: true)
				vm.manufacturer = "Sherwin-Williams"
				vm.colorName = "Agreeable Gray"
				vm.room = "Living Room"
				vm.save()

				let fetched = try await database.read { db in
					try PaintColor.find(UUID(0)).fetchOne(db)
				}
				let result = try #require(fetched)
				#expect(result.manufacturer == "Sherwin-Williams")
				#expect(result.colorName == "Agreeable Gray")
				#expect(result.room == "Living Room")
			}

			@Test("Save updates existing paint color in database")
			func saveUpdate() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						PaintColor.Draft(
							id: UUID(-3), profileID: nil,
							residenceID: UUID(-2),
							vehicleID: nil,
							manufacturer: "Behr",
							colorName: "Swiss Coffee"
						)
					}
				}

				let existing = try await database.read { db in
					try PaintColor.find(UUID(-3)).fetchOne(db)
				}
				let paintColor = try #require(existing)
				let vm = PaintColorEdit.ViewModel(paintColor: paintColor, isNew: false)
				vm.colorName = "Decorator's White"
				vm.save()

				let updated = try await database.read { db in
					try PaintColor.find(UUID(-3)).fetchOne(db)
				}
				#expect(updated?.colorName == "Decorator's White")
			}

			@Test("Delete removes paint color from database")
			func delete() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						PaintColor.Draft(id: UUID(-3), profileID: nil, residenceID: UUID(-2), vehicleID: nil)
					}
				}

				let existing = try await database.read { db in
					try PaintColor.find(UUID(-3)).fetchOne(db)
				}
				let paintColor = try #require(existing)
				let vm = PaintColorEdit.ViewModel(paintColor: paintColor, isNew: false)
				vm.delete()

				let count = try await database.read { db in
					try PaintColor.fetchCount(db)
				}
				#expect(count == 0)
			}
		}

		// MARK: - JobEdit.ViewModel

		@Suite("JobEdit")
		struct JobEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("Save inserts new job into database")
			func saveInsert() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					}
				}

				let job = Job(id: UUID(0), profileID: UUID(-1), company: "Acme")
				let vm = JobEdit.ViewModel(job: job, isNew: true)
				vm.company = "Acme"
				vm.jobTitle = "Engineer"
				vm.salary = 100_000
				vm.save()

				let fetched = try await database.read { db in
					try Job.find(UUID(0)).fetchOne(db)
				}
				let result = try #require(fetched)
				#expect(result.company == "Acme")
				#expect(result.title == "Engineer")
				#expect(result.salary == 100_000)
			}

			@Test("Save updates existing job in database")
			func saveUpdate() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Job.Draft(id: UUID(-2), profileID: UUID(-1), company: "Old Co")
					}
				}

				let existing = try await database.read { db in
					try Job.find(UUID(-2)).fetchOne(db)
				}
				let job = try #require(existing)
				let vm = JobEdit.ViewModel(job: job, isNew: false)
				vm.company = "New Co"
				vm.save()

				let updated = try await database.read { db in
					try Job.find(UUID(-2)).fetchOne(db)
				}
				#expect(updated?.company == "New Co")
			}

			@Test("Delete removes job from database")
			func delete() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Job.Draft(id: UUID(-2), profileID: UUID(-1), company: "Gone")
					}
				}

				let existing = try await database.read { db in
					try Job.find(UUID(-2)).fetchOne(db)
				}
				let job = try #require(existing)
				let vm = JobEdit.ViewModel(job: job, isNew: false)
				vm.delete()

				let count = try await database.read { db in
					try Job.fetchCount(db)
				}
				#expect(count == 0)
			}
		}

		// MARK: - UtilityEdit.ViewModel

		@Suite("UtilityEdit")
		struct UtilityEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("Save inserts new utility into database")
			func saveInsert() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
					}
				}

				let utility = Utility(id: UUID(0), residenceID: UUID(-2), provider: "ComEd")
				let vm = UtilityEdit.ViewModel(utility: utility, isNew: true)
				vm.provider = "ComEd"
				vm.type = .electric
				vm.save()

				let fetched = try await database.read { db in
					try Utility.find(UUID(0)).fetchOne(db)
				}
				let result = try #require(fetched)
				#expect(result.provider == "ComEd")
				#expect(result.type == .electric)
			}

			@Test("Save updates existing utility in database")
			func saveUpdate() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						Utility.Draft(id: UUID(-3), residenceID: UUID(-2), provider: "Old Provider")
					}
				}

				let existing = try await database.read { db in
					try Utility.find(UUID(-3)).fetchOne(db)
				}
				let utility = try #require(existing)
				let vm = UtilityEdit.ViewModel(utility: utility, isNew: false)
				vm.provider = "New Provider"
				vm.save()

				let updated = try await database.read { db in
					try Utility.find(UUID(-3)).fetchOne(db)
				}
				#expect(updated?.provider == "New Provider")
			}
		}

		// MARK: - DeviceEdit.ViewModel

		@Suite("DeviceEdit")
		struct DeviceEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("deleteConfirmationMessage uses brand and model, falls back when both empty")
			func deleteMessage() {
				let withName = Device(id: UUID(-1), profileID: UUID(-2), brand: "Apple", model: "MacBook Pro")
				let empty = Device(id: UUID(-3), profileID: UUID(-2))
				let vmWith = DeviceEdit.ViewModel(device: withName, isNew: false)
				let vmWithout = DeviceEdit.ViewModel(device: empty, isNew: false)

				#expect(vmWith.deleteConfirmationMessage.contains("Apple MacBook Pro"))
				#expect(vmWithout.deleteConfirmationMessage.contains("this device"))
			}

			@Test("itemNameForProfilePicker uses brand and model, falls back when empty")
			func itemName() {
				let withName = Device(id: UUID(-1), profileID: UUID(-2), brand: "Samsung", model: "Galaxy")
				let empty = Device(id: UUID(-3), profileID: UUID(-2))
				let vmWith = DeviceEdit.ViewModel(device: withName, isNew: false)
				let vmWithout = DeviceEdit.ViewModel(device: empty, isNew: false)

				#expect(vmWith.itemNameForProfilePicker == "Samsung Galaxy")
				#expect(vmWithout.itemNameForProfilePicker == "this device")
			}

			@Test("Save inserts new device into database")
			func saveInsert() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					}
				}

				let device = Device(id: UUID(0), profileID: UUID(-1), brand: "Apple", model: "iPad")
				let vm = DeviceEdit.ViewModel(device: device, isNew: true)
				vm.brand = "Apple"
				vm.model = "iPad"
				vm.save()

				let fetched = try await database.read { db in
					try Device.find(UUID(0)).fetchOne(db)
				}
				let result = try #require(fetched)
				#expect(result.brand == "Apple")
				#expect(result.model == "iPad")
			}
		}

		// MARK: - ServiceProviderEdit.ViewModel

		@Suite("ServiceProviderEdit")
		struct ServiceProviderEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("Save inserts new service provider into database")
			func saveInsert() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					}
				}

				let sp = ServiceProvider(id: UUID(0), profileID: UUID(-1), name: "Verizon")
				let vm = ServiceProviderEdit.ViewModel(serviceProvider: sp, isNew: true)
				vm.name = "Verizon"
				vm.providerType = .cell
				vm.monthlyCost = 80
				vm.save()

				let fetched = try await database.read { db in
					try ServiceProvider.find(UUID(0)).fetchOne(db)
				}
				let result = try #require(fetched)
				#expect(result.name == "Verizon")
				#expect(result.providerType == .cell)
				#expect(result.monthlyCost == 80)
			}
		}

		// MARK: - SubscriptionEdit.ViewModel

		@Suite("SubscriptionEdit")
		struct SubscriptionEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("Save inserts new subscription into database")
			func saveInsert() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					}
				}

				let sub = Subscription(
					id: UUID(0),
					profileID: UUID(-1),
					name: "Spotify",
					monthlyCost: 9.99,
					billingCycle: .monthly
				)
				let vm = SubscriptionEdit.ViewModel(subscription: sub, isNew: true)
				vm.name = "Spotify"
				vm.monthlyCost = 9.99
				vm.billingCycle = .monthly
				vm.save()

				let fetched = try await database.read { db in
					try Subscription.find(UUID(0)).fetchOne(db)
				}
				let result = try #require(fetched)
				#expect(result.name == "Spotify")
				#expect(result.monthlyCost == 9.99)
			}
		}

		// MARK: - BankAccountEdit.ViewModel

		@Suite("BankAccountEdit")
		struct BankAccountEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("Save inserts new bank account into database")
			func saveInsert() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					}
				}

				let account = BankAccount(id: UUID(0), profileID: UUID(-1), bankName: "Wells Fargo")
				let vm = BankAccountEdit.ViewModel(account: account, isNew: true)
				vm.bankName = "Wells Fargo"
				vm.accountType = .savings
				vm.save()

				let fetched = try await database.read { db in
					try BankAccount.find(UUID(0)).fetchOne(db)
				}
				let result = try #require(fetched)
				#expect(result.bankName == "Wells Fargo")
				#expect(result.accountType == .savings)
			}
		}

		// MARK: - InvestmentAccountEdit.ViewModel

		@Suite("InvestmentAccountEdit")
		struct InvestmentAccountEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("Save inserts new investment account into database")
			func saveInsert() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					}
				}

				let account = InvestmentAccount(
					id: UUID(0),
					profileID: UUID(-1),
					institution: "Vanguard"
				)
				let vm = InvestmentAccountEdit.ViewModel(account: account, isNew: true)
				vm.institution = "Vanguard"
				vm.accountType = .brokerage
				vm.save()

				let fetched = try await database.read { db in
					try InvestmentAccount.find(UUID(0)).fetchOne(db)
				}
				let result = try #require(fetched)
				#expect(result.institution == "Vanguard")
				#expect(result.accountType == .brokerage)
			}
		}

		// MARK: - HealthSavingsAccountEdit.ViewModel

		@Suite("HealthSavingsAccountEdit")
		struct HSAEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("Save inserts new HSA into database")
			func saveInsert() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
					}
				}

				let account = HealthSavingsAccount(
					id: UUID(0),
					profileID: UUID(-1),
					institution: "Lively"
				)
				let vm = HealthSavingsAccountEdit.ViewModel(account: account, isNew: true)
				vm.institution = "Lively"
				vm.accountType = .hsa
				vm.save()

				let fetched = try await database.read { db in
					try HealthSavingsAccount.find(UUID(0)).fetchOne(db)
				}
				let result = try #require(fetched)
				#expect(result.institution == "Lively")
				#expect(result.accountType == .hsa)
			}
		}

		// MARK: - InsuranceEdit.ViewModel

		@Suite("InsuranceEdit")
		struct InsuranceEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("Save inserts new insurance policy into database")
			func saveInsert() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Vehicle.Draft(id: UUID(-2), profileID: UUID(-1), make: "Toyota")
					}
				}

				let policy = InsurancePolicy(
					id: UUID(0),
					profileID: UUID(-1),
					vehicleID: UUID(-2),
					type: .auto,
					provider: "Geico"
				)
				let vm = InsuranceEdit.ViewModel(policy: policy, isNew: true)
				vm.provider = "Geico"
				vm.type = .auto
				vm.monthlyCost = 150
				vm.save()

				let fetched = try await database.read { db in
					try InsurancePolicy.find(UUID(0)).fetchOne(db)
				}
				let result = try #require(fetched)
				#expect(result.provider == "Geico")
				#expect(result.type == .auto)
				#expect(result.monthlyCost == 150)
			}
		}

		// MARK: - OtherEdit.ViewModel

		@Suite("OtherEdit")
		struct OtherEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("isValid requires non-empty trimmed name")
			func isValid() {
				let other = Other(id: UUID(-1), profileID: UUID(-2))
				let vm = OtherEdit.ViewModel(other: other, isNew: true)

				#expect(!vm.isValid)

				vm.name = "   "
				#expect(!vm.isValid)

				vm.name = "WiFi Router"
				#expect(vm.isValid)
			}

			@Test("itemNameForProfilePicker uses name, falls back when empty")
			func itemName() {
				let withName = Other(id: UUID(-1), profileID: UUID(-2), name: "Garage Door Opener")
				let empty = Other(id: UUID(-3), profileID: UUID(-2))
				let vmWith = OtherEdit.ViewModel(other: withName, isNew: false)
				let vmWithout = OtherEdit.ViewModel(other: empty, isNew: false)

				#expect(vmWith.itemNameForProfilePicker == "Garage Door Opener")
				#expect(vmWithout.itemNameForProfilePicker == "this item")
			}

			@Test("Save inserts new other item into database")
			func saveInsert() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
					}
				}

				let other = Other(
					id: UUID(0),
					profileID: UUID(-1),
					residenceID: UUID(-2),
					category: .homes,
					name: "Security System"
				)
				let vm = OtherEdit.ViewModel(other: other, isNew: true)
				vm.name = "Security System"
				vm.save()

				let fetched = try await database.read { db in
					try Other.find(UUID(0)).fetchOne(db)
				}
				let result = try #require(fetched)
				#expect(result.name == "Security System")
				#expect(result.category == .homes)
			}
		}

		// MARK: - MaintenanceItemEdit.ViewModel

		@Suite("MaintenanceItemEdit")
		struct MaintenanceItemEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("isValid requires non-empty trimmed name")
			func isValid() {
				let item = MaintenanceItem(id: UUID(-1), profileID: nil, residenceID: UUID(-2), vehicleID: nil)
				let vm = MaintenanceItemEdit.ViewModel(item: item, isNew: true)

				#expect(!vm.isValid)

				vm.name = "   "
				#expect(!vm.isValid)

				vm.name = "Air Filter"
				#expect(vm.isValid)
			}

			@Test("calculatedNextDueDate adds interval from lastCompletedAt")
			func calculatedNextDueDateFromCompletion() {
				let baseDate = Date(timeIntervalSince1970: 1_000_000)
				let item = MaintenanceItem(
					id: UUID(-1), profileID: nil,
					residenceID: UUID(-2),
					vehicleID: nil,
					intervalType: .month,
					intervalValue: 3,
					lastCompletedAt: baseDate
				)
				let vm = MaintenanceItemEdit.ViewModel(item: item, isNew: false)

				let expected = Calendar.current.date(
					byAdding: .month,
					value: 3,
					to: baseDate
				)!
				#expect(vm.calculatedNextDueDate == expected)
			}

			@Test("resetToAutomaticDueDate syncs due date and clears manual flag")
			func resetToAutomatic() {
				let baseDate = Date(timeIntervalSince1970: 1_000_000)
				let item = MaintenanceItem(
					id: UUID(-1), profileID: nil,
					residenceID: UUID(-2),
					vehicleID: nil,
					intervalType: .month,
					intervalValue: 1,
					lastCompletedAt: baseDate
				)
				let vm = MaintenanceItemEdit.ViewModel(item: item, isNew: true)
				vm.isUsingManualDueDate = true
				vm.dueDate = Date.distantFuture

				vm.resetToAutomaticDueDate()

				#expect(!vm.isUsingManualDueDate)
				let expected = Calendar.current.date(byAdding: .month, value: 1, to: baseDate)!
				#expect(vm.dueDate == expected)
			}

			@Test("Save inserts new maintenance item into database")
			func saveInsert() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
					}
				}

				let item = MaintenanceItem(
					id: UUID(0), profileID: nil,
					residenceID: UUID(-2),
					vehicleID: nil,
					name: "HVAC Filter"
				)
				let vm = MaintenanceItemEdit.ViewModel(item: item, isNew: true)
				vm.name = "HVAC Filter"
				vm.intervalType = .month
				vm.intervalValue = 3
				vm.save()

				let fetched = try await database.read { db in
					try MaintenanceItem.find(UUID(0)).fetchOne(db)
				}
				let result = try #require(fetched)
				#expect(result.name == "HVAC Filter")
				#expect(result.intervalType == .month)
				#expect(result.intervalValue == 3)
			}
		}

		// MARK: - ResidenceInfoEdit.ViewModel

		@Suite("ResidenceInfoEdit")
		struct ResidenceInfoEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("isValid requires non-empty trimmed street")
			func isValid() {
				let residence = Residence(id: UUID(-1), profileID: UUID(-2), street: "")
				let vm = ResidenceInfoEdit.ViewModel(residence: residence)

				#expect(!vm.isValid)

				vm.street = "   "
				#expect(!vm.isValid)

				vm.street = "456 Oak Ave"
				#expect(vm.isValid)
			}

			@Test("Save updates existing residence in database")
			func saveUpdate() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							street: "123 Main",
							city: "Springfield"
						)
					}
				}

				let existing = try await database.read { db in
					try Residence.find(UUID(-2)).fetchOne(db)
				}
				let residence = try #require(existing)
				let vm = ResidenceInfoEdit.ViewModel(residence: residence)
				vm.street = "456 Oak Ave"
				vm.city = "Portland"
				vm.save()

				let updated = try await database.read { db in
					try Residence.find(UUID(-2)).fetchOne(db)
				}
				#expect(updated?.street == "456 Oak Ave")
				#expect(updated?.city == "Portland")
			}

			@Test("Save clears moveOutDate when hasMoveOutDate is false")
			func saveClearsMoveOutDate() async throws {
				let moveOut = Date(timeIntervalSince1970: 2_000_000)
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							street: "123 Main",
							moveOutDate: moveOut
						)
					}
				}

				let existing = try await database.read { db in
					try Residence.find(UUID(-2)).fetchOne(db)
				}
				let residence = try #require(existing)
				let vm = ResidenceInfoEdit.ViewModel(residence: residence)
				vm.hasMoveOutDate = false
				vm.save()

				let updated = try await database.read { db in
					try Residence.find(UUID(-2)).fetchOne(db)
				}
				#expect(updated?.moveOutDate == nil)
			}
		}

		// MARK: - VehicleInfoEdit.ViewModel

		@Suite("VehicleInfoEdit")
		struct VehicleInfoEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("isValid requires non-empty trimmed make")
			func isValid() {
				let vehicle = Vehicle(id: UUID(-1), profileID: UUID(-2), make: "")
				let vm = VehicleInfoEdit.ViewModel(vehicle: vehicle)

				#expect(!vm.isValid)

				vm.make = "   "
				#expect(!vm.isValid)

				vm.make = "Honda"
				#expect(vm.isValid)
			}

			@Test("Save updates existing vehicle in database")
			func saveUpdate() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Vehicle.Draft(id: UUID(-2), profileID: UUID(-1), make: "Toyota", model: "Camry")
					}
				}

				let existing = try await database.read { db in
					try Vehicle.find(UUID(-2)).fetchOne(db)
				}
				let vehicle = try #require(existing)
				let vm = VehicleInfoEdit.ViewModel(vehicle: vehicle)
				vm.make = "Honda"
				vm.model = "Accord"
				vm.save()

				let updated = try await database.read { db in
					try Vehicle.find(UUID(-2)).fetchOne(db)
				}
				#expect(updated?.make == "Honda")
				#expect(updated?.model == "Accord")
			}
		}
	}
}
