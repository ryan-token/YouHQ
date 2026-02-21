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

			@Test("Title shows Add for new, Edit for existing")
			func title() {
				let paintColor = PaintColor(id: UUID(-1), residenceID: UUID(-2), vehicleID: nil)
				let newVM = PaintColorEdit.ViewModel(paintColor: paintColor, isNew: true)
				let editVM = PaintColorEdit.ViewModel(paintColor: paintColor, isNew: false)

				#expect(newVM.title == "Add Paint Color")
				#expect(editVM.title == "Edit Paint Color")
			}

			@Test("isValid is always true")
			func isValid() {
				let paintColor = PaintColor(id: UUID(-1), residenceID: UUID(-2), vehicleID: nil)
				let vm = PaintColorEdit.ViewModel(paintColor: paintColor, isNew: true)
				#expect(vm.isValid)
			}

			@Test("deleteConfirmationMessage uses room when present")
			func deleteMessageWithRoom() {
				let paintColor = PaintColor(id: UUID(-1), residenceID: UUID(-2), vehicleID: nil, room: "Kitchen")
				let vm = PaintColorEdit.ViewModel(paintColor: paintColor, isNew: false)
				#expect(vm.deleteConfirmationMessage == "Are you sure you want to delete Kitchen?")
			}

			@Test("deleteConfirmationMessage falls back when room is empty")
			func deleteMessageWithoutRoom() {
				let paintColor = PaintColor(id: UUID(-1), residenceID: UUID(-2), vehicleID: nil, room: "")
				let vm = PaintColorEdit.ViewModel(paintColor: paintColor, isNew: false)
				#expect(vm.deleteConfirmationMessage == "Are you sure you want to delete this paint color?")
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
					id: UUID(0),
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
							id: UUID(-3),
							residenceID: UUID(-2),
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
						PaintColor.Draft(id: UUID(-3), residenceID: UUID(-2))
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

			@Test("Title shows Add for new, Edit for existing")
			func title() {
				let job = Job(id: UUID(-1), profileID: UUID(-2))
				let newVM = JobEdit.ViewModel(job: job, isNew: true)
				let editVM = JobEdit.ViewModel(job: job, isNew: false)

				#expect(newVM.title == "Add Job")
				#expect(editVM.title == "Edit Job")
			}

			@Test("isValid is always true")
			func isValid() {
				let job = Job(id: UUID(-1), profileID: UUID(-2))
				let vm = JobEdit.ViewModel(job: job, isNew: true)
				#expect(vm.isValid)
			}

			@Test("deleteConfirmationMessage uses company when present")
			func deleteMessageWithCompany() {
				let job = Job(id: UUID(-1), profileID: UUID(-2), company: "Apple")
				let vm = JobEdit.ViewModel(job: job, isNew: false)
				#expect(vm.deleteConfirmationMessage.contains("Apple"))
			}

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

			@Test("Title shows Add for new, Edit for existing")
			func title() {
				let utility = Utility(id: UUID(-1), residenceID: UUID(-2))
				let newVM = UtilityEdit.ViewModel(utility: utility, isNew: true)
				let editVM = UtilityEdit.ViewModel(utility: utility, isNew: false)

				#expect(newVM.title == "Add Utility")
				#expect(editVM.title == "Edit Utility")
			}

			@Test("isValid is always true")
			func isValid() {
				let utility = Utility(id: UUID(-1), residenceID: UUID(-2))
				let vm = UtilityEdit.ViewModel(utility: utility, isNew: true)
				#expect(vm.isValid)
			}

			@Test("deleteConfirmationMessage includes provider and type")
			func deleteMessage() {
				let utility = Utility(
					id: UUID(-1),
					residenceID: UUID(-2),
					type: .electric,
					provider: "Duke Energy"
				)
				let vm = UtilityEdit.ViewModel(utility: utility, isNew: false)
				#expect(vm.deleteConfirmationMessage.contains("Duke Energy"))
				#expect(vm.deleteConfirmationMessage.contains("Electric"))
			}

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

			@Test("Delete removes utility from database")
			func delete() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						Utility.Draft(id: UUID(-3), residenceID: UUID(-2))
					}
				}

				let existing = try await database.read { db in
					try Utility.find(UUID(-3)).fetchOne(db)
				}
				let utility = try #require(existing)
				let vm = UtilityEdit.ViewModel(utility: utility, isNew: false)
				vm.delete()

				let count = try await database.read { db in
					try Utility.fetchCount(db)
				}
				#expect(count == 0)
			}
		}

		// MARK: - DeviceEdit.ViewModel

		@Suite("DeviceEdit")
		struct DeviceEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("Title shows Add for new, Edit for existing")
			func title() {
				let device = Device(id: UUID(-1), profileID: UUID(-2))
				let newVM = DeviceEdit.ViewModel(device: device, isNew: true)
				let editVM = DeviceEdit.ViewModel(device: device, isNew: false)

				#expect(newVM.title == "Add Device")
				#expect(editVM.title == "Edit Device")
			}

			@Test("isValid is always true")
			func isValid() {
				let device = Device(id: UUID(-1), profileID: UUID(-2))
				let vm = DeviceEdit.ViewModel(device: device, isNew: true)
				#expect(vm.isValid)
			}

			@Test("deleteConfirmationMessage uses brand and model when present")
			func deleteMessageWithName() {
				let device = Device(id: UUID(-1), profileID: UUID(-2), brand: "Apple", model: "MacBook Pro")
				let vm = DeviceEdit.ViewModel(device: device, isNew: false)
				#expect(vm.deleteConfirmationMessage.contains("Apple MacBook Pro"))
			}

			@Test("deleteConfirmationMessage falls back when brand and model are empty")
			func deleteMessageFallback() {
				let device = Device(id: UUID(-1), profileID: UUID(-2))
				let vm = DeviceEdit.ViewModel(device: device, isNew: false)
				#expect(vm.deleteConfirmationMessage.contains("this device"))
			}

			@Test("itemNameForProfilePicker uses brand and model")
			func itemNameWithBrandModel() {
				let device = Device(id: UUID(-1), profileID: UUID(-2), brand: "Samsung", model: "Galaxy")
				let vm = DeviceEdit.ViewModel(device: device, isNew: false)
				#expect(vm.itemNameForProfilePicker == "Samsung Galaxy")
			}

			@Test("itemNameForProfilePicker falls back to this device")
			func itemNameFallback() {
				let device = Device(id: UUID(-1), profileID: UUID(-2))
				let vm = DeviceEdit.ViewModel(device: device, isNew: false)
				#expect(vm.itemNameForProfilePicker == "this device")
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

			@Test("Delete removes device from database")
			func delete() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Device.Draft(id: UUID(-2), profileID: UUID(-1))
					}
				}

				let existing = try await database.read { db in
					try Device.find(UUID(-2)).fetchOne(db)
				}
				let device = try #require(existing)
				let vm = DeviceEdit.ViewModel(device: device, isNew: false)
				vm.delete()

				let count = try await database.read { db in
					try Device.fetchCount(db)
				}
				#expect(count == 0)
			}
		}

		// MARK: - ServiceProviderEdit.ViewModel

		@Suite("ServiceProviderEdit")
		struct ServiceProviderEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("Title shows Add for new, Edit for existing")
			func title() {
				let sp = ServiceProvider(id: UUID(-1), profileID: UUID(-2))
				let newVM = ServiceProviderEdit.ViewModel(serviceProvider: sp, isNew: true)
				let editVM = ServiceProviderEdit.ViewModel(serviceProvider: sp, isNew: false)

				#expect(newVM.title == "Add Service Provider")
				#expect(editVM.title == "Edit Service Provider")
			}

			@Test("isValid is always true")
			func isValid() {
				let sp = ServiceProvider(id: UUID(-1), profileID: UUID(-2))
				let vm = ServiceProviderEdit.ViewModel(serviceProvider: sp, isNew: true)
				#expect(vm.isValid)
			}

			@Test("deleteConfirmationMessage uses name when present")
			func deleteMessageWithName() {
				let sp = ServiceProvider(id: UUID(-1), profileID: UUID(-2), name: "AT&T")
				let vm = ServiceProviderEdit.ViewModel(serviceProvider: sp, isNew: false)
				#expect(vm.deleteConfirmationMessage.contains("AT&T"))
			}

			@Test("deleteConfirmationMessage falls back when name is empty")
			func deleteMessageFallback() {
				let sp = ServiceProvider(id: UUID(-1), profileID: UUID(-2))
				let vm = ServiceProviderEdit.ViewModel(serviceProvider: sp, isNew: false)
				#expect(vm.deleteConfirmationMessage.contains("this service provider"))
			}

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

			@Test("Delete removes service provider from database")
			func delete() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						ServiceProvider.Draft(id: UUID(-2), profileID: UUID(-1), name: "Comcast")
					}
				}

				let existing = try await database.read { db in
					try ServiceProvider.find(UUID(-2)).fetchOne(db)
				}
				let sp = try #require(existing)
				let vm = ServiceProviderEdit.ViewModel(serviceProvider: sp, isNew: false)
				vm.delete()

				let count = try await database.read { db in
					try ServiceProvider.fetchCount(db)
				}
				#expect(count == 0)
			}
		}

		// MARK: - SubscriptionEdit.ViewModel

		@Suite("SubscriptionEdit")
		struct SubscriptionEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("Title shows Add for new, Edit for existing")
			func title() {
				let sub = Subscription(id: UUID(-1), profileID: UUID(-2))
				let newVM = SubscriptionEdit.ViewModel(subscription: sub, isNew: true)
				let editVM = SubscriptionEdit.ViewModel(subscription: sub, isNew: false)

				#expect(newVM.title == "Add Subscription")
				#expect(editVM.title == "Edit Subscription")
			}

			@Test("isValid is always true")
			func isValid() {
				let sub = Subscription(id: UUID(-1), profileID: UUID(-2))
				let vm = SubscriptionEdit.ViewModel(subscription: sub, isNew: true)
				#expect(vm.isValid)
			}

			@Test("deleteConfirmationMessage uses name when present")
			func deleteMessageWithName() {
				let sub = Subscription(id: UUID(-1), profileID: UUID(-2), name: "Netflix")
				let vm = SubscriptionEdit.ViewModel(subscription: sub, isNew: false)
				#expect(vm.deleteConfirmationMessage.contains("Netflix"))
			}

			@Test("deleteConfirmationMessage falls back when name is empty")
			func deleteMessageFallback() {
				let sub = Subscription(id: UUID(-1), profileID: UUID(-2))
				let vm = SubscriptionEdit.ViewModel(subscription: sub, isNew: false)
				#expect(vm.deleteConfirmationMessage.contains("this subscription"))
			}

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

			@Test("Delete removes subscription from database")
			func delete() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Subscription.Draft(id: UUID(-2), profileID: UUID(-1), name: "Hulu")
					}
				}

				let existing = try await database.read { db in
					try Subscription.find(UUID(-2)).fetchOne(db)
				}
				let sub = try #require(existing)
				let vm = SubscriptionEdit.ViewModel(subscription: sub, isNew: false)
				vm.delete()

				let count = try await database.read { db in
					try Subscription.fetchCount(db)
				}
				#expect(count == 0)
			}
		}

		// MARK: - BankAccountEdit.ViewModel

		@Suite("BankAccountEdit")
		struct BankAccountEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("Title shows Add for new, Edit for existing")
			func title() {
				let account = BankAccount(id: UUID(-1), profileID: UUID(-2))
				let newVM = BankAccountEdit.ViewModel(account: account, isNew: true)
				let editVM = BankAccountEdit.ViewModel(account: account, isNew: false)

				#expect(newVM.title == "Add Bank Account")
				#expect(editVM.title == "Edit Bank Account")
			}

			@Test("isValid is always true")
			func isValid() {
				let account = BankAccount(id: UUID(-1), profileID: UUID(-2))
				let vm = BankAccountEdit.ViewModel(account: account, isNew: true)
				#expect(vm.isValid)
			}

			@Test("deleteConfirmationMessage includes bank name and type")
			func deleteMessage() {
				let account = BankAccount(
					id: UUID(-1),
					profileID: UUID(-2),
					bankName: "Chase",
					accountType: .checking
				)
				let vm = BankAccountEdit.ViewModel(account: account, isNew: false)
				#expect(vm.deleteConfirmationMessage.contains("Chase"))
				#expect(vm.deleteConfirmationMessage.contains("Checking"))
			}

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

			@Test("Delete removes bank account from database")
			func delete() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						BankAccount.Draft(id: UUID(-2), profileID: UUID(-1))
					}
				}

				let existing = try await database.read { db in
					try BankAccount.find(UUID(-2)).fetchOne(db)
				}
				let account = try #require(existing)
				let vm = BankAccountEdit.ViewModel(account: account, isNew: false)
				vm.delete()

				let count = try await database.read { db in
					try BankAccount.fetchCount(db)
				}
				#expect(count == 0)
			}
		}

		// MARK: - InvestmentAccountEdit.ViewModel

		@Suite("InvestmentAccountEdit")
		struct InvestmentAccountEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("Title shows Add for new, Edit for existing")
			func title() {
				let account = InvestmentAccount(id: UUID(-1), profileID: UUID(-2))
				let newVM = InvestmentAccountEdit.ViewModel(account: account, isNew: true)
				let editVM = InvestmentAccountEdit.ViewModel(account: account, isNew: false)

				#expect(newVM.title == "Add Investment Account")
				#expect(editVM.title == "Edit Investment Account")
			}

			@Test("isValid is always true")
			func isValid() {
				let account = InvestmentAccount(id: UUID(-1), profileID: UUID(-2))
				let vm = InvestmentAccountEdit.ViewModel(account: account, isNew: true)
				#expect(vm.isValid)
			}

			@Test("deleteConfirmationMessage includes institution and type")
			func deleteMessage() {
				let account = InvestmentAccount(
					id: UUID(-1),
					profileID: UUID(-2),
					institution: "Fidelity",
					accountType: .rothIRA
				)
				let vm = InvestmentAccountEdit.ViewModel(account: account, isNew: false)
				#expect(vm.deleteConfirmationMessage.contains("Fidelity"))
				#expect(vm.deleteConfirmationMessage.contains("Roth IRA"))
			}

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

			@Test("Delete removes investment account from database")
			func delete() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						InvestmentAccount.Draft(id: UUID(-2), profileID: UUID(-1))
					}
				}

				let existing = try await database.read { db in
					try InvestmentAccount.find(UUID(-2)).fetchOne(db)
				}
				let account = try #require(existing)
				let vm = InvestmentAccountEdit.ViewModel(account: account, isNew: false)
				vm.delete()

				let count = try await database.read { db in
					try InvestmentAccount.fetchCount(db)
				}
				#expect(count == 0)
			}
		}

		// MARK: - HealthSavingsAccountEdit.ViewModel

		@Suite("HealthSavingsAccountEdit")
		struct HSAEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("Title shows Add for new, Edit for existing")
			func title() {
				let account = HealthSavingsAccount(id: UUID(-1), profileID: UUID(-2))
				let newVM = HealthSavingsAccountEdit.ViewModel(account: account, isNew: true)
				let editVM = HealthSavingsAccountEdit.ViewModel(account: account, isNew: false)

				#expect(newVM.title == "Add HSA/FSA")
				#expect(editVM.title == "Edit HSA/FSA")
			}

			@Test("isValid is always true")
			func isValid() {
				let account = HealthSavingsAccount(id: UUID(-1), profileID: UUID(-2))
				let vm = HealthSavingsAccountEdit.ViewModel(account: account, isNew: true)
				#expect(vm.isValid)
			}

			@Test("deleteConfirmationMessage includes institution and type")
			func deleteMessage() {
				let account = HealthSavingsAccount(
					id: UUID(-1),
					profileID: UUID(-2),
					accountType: .fsa,
					institution: "HealthEquity"
				)
				let vm = HealthSavingsAccountEdit.ViewModel(account: account, isNew: false)
				#expect(vm.deleteConfirmationMessage.contains("HealthEquity"))
				#expect(vm.deleteConfirmationMessage.contains("FSA"))
			}

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

			@Test("Delete removes HSA from database")
			func delete() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						HealthSavingsAccount.Draft(id: UUID(-2), profileID: UUID(-1))
					}
				}

				let existing = try await database.read { db in
					try HealthSavingsAccount.find(UUID(-2)).fetchOne(db)
				}
				let account = try #require(existing)
				let vm = HealthSavingsAccountEdit.ViewModel(account: account, isNew: false)
				vm.delete()

				let count = try await database.read { db in
					try HealthSavingsAccount.fetchCount(db)
				}
				#expect(count == 0)
			}
		}

		// MARK: - InsuranceEdit.ViewModel

		@Suite("InsuranceEdit")
		struct InsuranceEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("Title shows Add for new, Edit for existing")
			func title() {
				let policy = InsurancePolicy(id: UUID(-1), profileID: UUID(-2))
				let newVM = InsuranceEdit.ViewModel(policy: policy, isNew: true)
				let editVM = InsuranceEdit.ViewModel(policy: policy, isNew: false)

				#expect(newVM.title == "Add Policy")
				#expect(editVM.title == "Edit Policy")
			}

			@Test("isValid is always true")
			func isValid() {
				let policy = InsurancePolicy(id: UUID(-1), profileID: UUID(-2))
				let vm = InsuranceEdit.ViewModel(policy: policy, isNew: true)
				#expect(vm.isValid)
			}

			@Test("deleteConfirmationMessage includes provider and type")
			func deleteMessage() {
				let policy = InsurancePolicy(
					id: UUID(-1),
					profileID: UUID(-2),
					type: .auto,
					provider: "State Farm"
				)
				let vm = InsuranceEdit.ViewModel(policy: policy, isNew: false)
				#expect(vm.deleteConfirmationMessage.contains("State Farm"))
				#expect(vm.deleteConfirmationMessage.contains("Auto"))
			}

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

			@Test("Delete removes insurance policy from database")
			func delete() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						InsurancePolicy.Draft(
							id: UUID(-2),
							profileID: UUID(-1),
							type: .health,
							provider: "Aetna"
						)
					}
				}

				let existing = try await database.read { db in
					try InsurancePolicy.find(UUID(-2)).fetchOne(db)
				}
				let policy = try #require(existing)
				let vm = InsuranceEdit.ViewModel(policy: policy, isNew: false)
				vm.delete()

				let count = try await database.read { db in
					try InsurancePolicy.fetchCount(db)
				}
				#expect(count == 0)
			}
		}

		// MARK: - OtherEdit.ViewModel

		@Suite("OtherEdit")
		struct OtherEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("Title shows Add for new, Edit for existing")
			func title() {
				let other = Other(id: UUID(-1), profileID: UUID(-2))
				let newVM = OtherEdit.ViewModel(other: other, isNew: true)
				let editVM = OtherEdit.ViewModel(other: other, isNew: false)

				#expect(newVM.title == "Add Other")
				#expect(editVM.title == "Edit Other")
			}

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

			@Test("deleteConfirmationMessage is static")
			func deleteMessage() {
				let other = Other(id: UUID(-1), profileID: UUID(-2), name: "Test Item")
				let vm = OtherEdit.ViewModel(other: other, isNew: false)
				#expect(vm.deleteConfirmationMessage == "Are you sure you want to delete this?")
			}

			@Test("itemNameForProfilePicker uses name when present")
			func itemNameWithName() {
				let other = Other(id: UUID(-1), profileID: UUID(-2), name: "Garage Door Opener")
				let vm = OtherEdit.ViewModel(other: other, isNew: false)
				#expect(vm.itemNameForProfilePicker == "Garage Door Opener")
			}

			@Test("itemNameForProfilePicker falls back to this item")
			func itemNameFallback() {
				let other = Other(id: UUID(-1), profileID: UUID(-2))
				let vm = OtherEdit.ViewModel(other: other, isNew: false)
				#expect(vm.itemNameForProfilePicker == "this item")
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

			@Test("Delete removes other item from database")
			func delete() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Other.Draft(id: UUID(-2), profileID: UUID(-1), category: .career, name: "Test Item")
					}
				}

				let existing = try await database.read { db in
					try Other.find(UUID(-2)).fetchOne(db)
				}
				let other = try #require(existing)
				let vm = OtherEdit.ViewModel(other: other, isNew: false)
				vm.delete()

				let count = try await database.read { db in
					try Other.fetchCount(db)
				}
				#expect(count == 0)
			}
		}

		// MARK: - MaintenanceItemEdit.ViewModel

		@Suite("MaintenanceItemEdit")
		struct MaintenanceItemEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("Title shows Add for new, Edit for existing")
			func title() {
				let item = MaintenanceItem(id: UUID(-1), residenceID: UUID(-2), vehicleID: nil)
				let newVM = MaintenanceItemEdit.ViewModel(item: item, isNew: true)
				let editVM = MaintenanceItemEdit.ViewModel(item: item, isNew: false)

				#expect(newVM.title == "Add Maintenance Item")
				#expect(editVM.title == "Edit Item")
			}

			@Test("isValid requires non-empty trimmed name")
			func isValid() {
				let item = MaintenanceItem(id: UUID(-1), residenceID: UUID(-2), vehicleID: nil)
				let vm = MaintenanceItemEdit.ViewModel(item: item, isNew: true)

				#expect(!vm.isValid)

				vm.name = "   "
				#expect(!vm.isValid)

				vm.name = "Air Filter"
				#expect(vm.isValid)
			}

			@Test("deleteConfirmationMessage includes item name")
			func deleteMessage() {
				let item = MaintenanceItem(
					id: UUID(-1),
					residenceID: UUID(-2),
					vehicleID: nil,
					name: "Furnace Filter"
				)
				let vm = MaintenanceItemEdit.ViewModel(item: item, isNew: false)
				#expect(vm.deleteConfirmationMessage.contains("Furnace Filter"))
			}

			@Test("calculatedNextDueDate adds interval from lastCompletedAt")
			func calculatedNextDueDateFromCompletion() {
				let baseDate = Date(timeIntervalSince1970: 1_000_000)
				let item = MaintenanceItem(
					id: UUID(-1),
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
					id: UUID(-1),
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
				// With a fixed lastCompletedAt, the calculated date is deterministic
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
					id: UUID(0),
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

			@Test("Delete removes maintenance item from database")
			func delete() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						MaintenanceItem.Draft(
							id: UUID(-3),
							residenceID: UUID(-2),
							vehicleID: nil,
							name: "Gutter Cleaning"
						)
					}
				}

				let existing = try await database.read { db in
					try MaintenanceItem.find(UUID(-3)).fetchOne(db)
				}
				let item = try #require(existing)
				let vm = MaintenanceItemEdit.ViewModel(item: item, isNew: false)
				vm.delete()

				let count = try await database.read { db in
					try MaintenanceItem.fetchCount(db)
				}
				#expect(count == 0)
			}
		}

		// MARK: - ResidenceInfoEdit.ViewModel

		@Suite("ResidenceInfoEdit")
		struct ResidenceInfoEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("Title is always Edit Residence")
			func title() {
				let residence = Residence(id: UUID(-1), profileID: UUID(-2), street: "123 Main")
				let vm = ResidenceInfoEdit.ViewModel(residence: residence)
				#expect(vm.title == "Edit Residence")
			}

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

			@Test("deleteConfirmationMessage warns about cascade")
			func deleteMessage() {
				let residence = Residence(id: UUID(-1), profileID: UUID(-2), street: "123 Main")
				let vm = ResidenceInfoEdit.ViewModel(residence: residence)
				#expect(vm.deleteConfirmationMessage.contains("utilities"))
				#expect(vm.deleteConfirmationMessage.contains("insurance"))
				#expect(vm.deleteConfirmationMessage.contains("maintenance"))
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

			@Test("Delete removes residence and cascades")
			func delete() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						Utility.Draft(id: UUID(-3), residenceID: UUID(-2))
					}
				}

				let existing = try await database.read { db in
					try Residence.find(UUID(-2)).fetchOne(db)
				}
				let residence = try #require(existing)
				let vm = ResidenceInfoEdit.ViewModel(residence: residence)
				vm.delete()

				let residenceCount = try await database.read { db in try Residence.fetchCount(db) }
				let utilityCount = try await database.read { db in try Utility.fetchCount(db) }
				#expect(residenceCount == 0)
				#expect(utilityCount == 0)
			}
		}

		// MARK: - VehicleInfoEdit.ViewModel

		@Suite("VehicleInfoEdit")
		struct VehicleInfoEditTests {
			@Dependency(\.defaultDatabase) var database

			@Test("Title is always Edit Vehicle")
			func title() {
				let vehicle = Vehicle(id: UUID(-1), profileID: UUID(-2), make: "Toyota")
				let vm = VehicleInfoEdit.ViewModel(vehicle: vehicle)
				#expect(vm.title == "Edit Vehicle")
			}

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

			@Test("deleteConfirmationMessage warns about cascade")
			func deleteMessage() {
				let vehicle = Vehicle(id: UUID(-1), profileID: UUID(-2), make: "Toyota")
				let vm = VehicleInfoEdit.ViewModel(vehicle: vehicle)
				#expect(vm.deleteConfirmationMessage.contains("insurance"))
				#expect(vm.deleteConfirmationMessage.contains("maintenance"))
				#expect(vm.deleteConfirmationMessage.contains("paint colors"))
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

			@Test("Delete removes vehicle and cascades")
			func delete() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Vehicle.Draft(id: UUID(-2), profileID: UUID(-1), make: "Ford")
						InsurancePolicy.Draft(
							id: UUID(-3),
							profileID: UUID(-1),
							vehicleID: UUID(-2),
							type: .auto
						)
					}
				}

				let existing = try await database.read { db in
					try Vehicle.find(UUID(-2)).fetchOne(db)
				}
				let vehicle = try #require(existing)
				let vm = VehicleInfoEdit.ViewModel(vehicle: vehicle)
				vm.delete()

				let vehicleCount = try await database.read { db in try Vehicle.fetchCount(db) }
				let insuranceCount = try await database.read { db in try InsurancePolicy.fetchCount(db) }
				#expect(vehicleCount == 0)
				#expect(insuranceCount == 0)
			}
		}
	}
}
