//
//  DatabaseWriter+ScreenshotSeed.swift
//  YouHQ
//
//  Used to populate every simulator with identical, App Store-ready sample
//  data so screenshots stay consistent across devices.
//

#if DEBUG

	import Foundation
	import SQLiteData

	extension DatabaseWriter {
		/// Wipes the database of profiles (cascades to all related data) and
		/// inserts the canonical App Store screenshot data set.
		func seedScreenshotData() throws {
			try write { db in
				// Delete every profile — cascades delete all children.
				try Profile.delete().execute(db)

				let appStoreProfileID = UUID()
				let ryanProfileID = UUID()
				let now = Date()

				let denverID = UUID()
				let morrisonID = UUID()
				let civicID = UUID()
				let renegadeID = UUID()

				try db.seed {
					Profile.Draft(
						id: appStoreProfileID,
						name: "App Store",
						createdAt: now,
						updatedAt: now
					)
					Profile.Draft(
						id: ryanProfileID,
						name: "Ryan",
						createdAt: now,
						updatedAt: now
					)
				}

				try seedResidences(
					db: db,
					profileID: appStoreProfileID,
					denverID: denverID,
					morrisonID: morrisonID
				)

				try seedVehicles(
					db: db,
					profileID: appStoreProfileID,
					civicID: civicID,
					renegadeID: renegadeID
				)

				try seedMoney(db: db, profileID: appStoreProfileID)
				try seedMedia(db: db, profileID: appStoreProfileID)
				try seedCareer(db: db, profileID: appStoreProfileID)

				print("✅ Screenshot sample data seeded successfully")
			}
		}

		// MARK: - Residence

		private func seedResidences(
			db: Database,
			profileID: Profile.ID,
			denverID: Residence.ID,
			morrisonID: Residence.ID
		) throws {
			try db.seed {
				Residence.Draft(
					id: denverID,
					profileID: profileID,
					type: .house,
					street: "1340 Pennsylvania St",
					unit: "",
					city: "Denver",
					state: "CO",
					zipCode: "80203",
					country: "USA",
					moveInDate: .components(year: 2000, month: 1, day: 1),
					moveOutDate: nil,
					isCurrent: true,
					monthlyCost: 3000,
					costType: .rent,
					backgroundColor: "indigo",
					notes: "Our Denver home ❤️"
				)

				Residence.Draft(
					id: morrisonID,
					profileID: profileID,
					type: .apartment,
					street: "18300 W Alameda Pkwy",
					unit: "",
					city: "Morrison",
					state: "CO",
					zipCode: "",
					country: "USA",
					moveInDate: nil,
					moveOutDate: nil,
					isCurrent: false,
					monthlyCost: nil,
					costType: .rent,
					notes: ""
				)

				Utility.Draft(
					residenceID: denverID,
					type: .electric,
					provider: "Xcel Energy",
					accountNumber: "1234567890",
					approximateMonthlyCost: 75,
					backgroundColor: "#F6D045",
					url: "xcelenergy.com",
					notes: ""
				)

				Utility.Draft(
					residenceID: denverID,
					type: .gas,
					provider: "Xcel Energy",
					accountNumber: "0987654321",
					approximateMonthlyCost: 70,
					backgroundColor: "#3783EF",
					url: "xcelenergy.com",
					notes: "Yes, Xcel handles both electric and gas."
				)
			}
		}

		// MARK: - Vehicles

		private func seedVehicles(
			db: Database,
			profileID: Profile.ID,
			civicID: Vehicle.ID,
			renegadeID: Vehicle.ID
		) throws {
			try db.seed {
				Vehicle.Draft(
					id: civicID,
					profileID: profileID,
					type: .car,
					subType: .gas,
					make: "Honda",
					model: "Civic",
					year: "2021",
					color: "Blue",
					vin: nil,
					monthlyCost: 657,
					costType: .loanPayment,
					backgroundColor: "#2C60F0",
					notes: ""
				)

				Vehicle.Draft(
					id: renegadeID,
					profileID: profileID,
					type: .car,
					subType: .gas,
					make: "Jeep",
					model: "Renegade",
					year: "2017",
					color: "Grey",
					vin: nil,
					monthlyCost: nil,
					costType: .owned,
					notes: ""
				)

				InsurancePolicy.Draft(
					profileID: profileID,
					residenceID: nil,
					vehicleID: civicID,
					type: .auto,
					provider: "State Farm",
					policyNumber: "",
					monthlyCost: 179,
					deductible: nil,
					coverageAmount: nil,
					startDate: nil,
					renewalDate: nil,
					isActive: true,
					backgroundColor: "red",
					url: "statefarm.com",
					notes: ""
				)

				PaintColor.Draft(
					profileID: nil,
					residenceID: nil,
					vehicleID: civicID,
					manufacturer: "",
					colorName: "Magenta",
					colorCode: "",
					room: "Exterior",
					finish: .eggshell,
					purchaseDate: nil,
					surfaceType: "Exterior",
					storePurchasedFrom: "",
					applicationDate: nil,
					notes: ""
				)

				PaintColor.Draft(
					profileID: nil,
					residenceID: nil,
					vehicleID: civicID,
					manufacturer: "",
					colorName: "Dark Grey",
					colorCode: "",
					room: "Interior",
					finish: .semiGloss,
					purchaseDate: nil,
					surfaceType: "Interior",
					storePurchasedFrom: "",
					applicationDate: nil,
					notes: ""
				)

				MaintenanceItem.Draft(
					profileID: nil,
					residenceID: nil,
					vehicleID: civicID,
					name: "Oil Change",
					itemDescription: "",
					intervalType: .month,
					intervalValue: 1,
					lastCompletedAt: nil,
					dueDate: .components(year: 2026, month: 6, day: 20),
					shouldNotify: true,
					notificationIdentifier: "",
					notes: ""
				)

				MaintenanceItem.Draft(
					profileID: nil,
					residenceID: nil,
					vehicleID: civicID,
					name: "AC Issue",
					itemDescription: "",
					intervalType: .month,
					intervalValue: 1,
					lastCompletedAt: nil,
					dueDate: .components(year: 2026, month: 6, day: 20),
					shouldNotify: true,
					notificationIdentifier: "",
					notes: ""
				)

				MaintenanceItem.Draft(
					profileID: nil,
					residenceID: nil,
					vehicleID: civicID,
					name: "Some third thing",
					itemDescription: "",
					intervalType: .month,
					intervalValue: 3,
					lastCompletedAt: nil,
					dueDate: .components(year: 2026, month: 8, day: 22),
					shouldNotify: true,
					notificationIdentifier: "",
					notes: ""
				)
			}
		}

		// MARK: - Money

		private func seedMoney(db: Database, profileID: Profile.ID) throws {
			try db.seed {
				BankAccount.Draft(
					profileID: profileID,
					bankName: "Ally Bank",
					accountType: .checking,
					accountNumber: "1234567890",
					routingNumber: "0987654321",
					isActive: true,
					backgroundColor: "#6E1FA2",
					url: "ally.com",
					notes: ""
				)

				BankAccount.Draft(
					profileID: profileID,
					bankName: "Mercury",
					accountType: .savings,
					accountNumber: "1234567890",
					routingNumber: "",
					isActive: true,
					backgroundColor: "#E0B979",
					url: "mercury.com",
					notes: ""
				)

				InvestmentAccount.Draft(
					profileID: profileID,
					institution: "Charles Schwab",
					accountType: .brokerage,
					accountNumber: "1223334444",
					isActive: true,
					backgroundColor: "#4394E5",
					url: "schwab.com",
					notes: ""
				)

				HealthSavingsAccount.Draft(
					profileID: profileID,
					accountType: .hsa,
					institution: "HSA Bank",
					accountNumber: "4444333221",
					isActive: true,
					backgroundColor: "#438E93",
					url: "hsabank.com",
					notes: ""
				)
			}
		}

		// MARK: - Media

		private func seedMedia(db: Database, profileID: Profile.ID) throws {
			try db.seed {
				ServiceProvider.Draft(
					profileID: profileID,
					providerType: .internet,
					name: "BAM Broadband",
					monthlyCost: 66,
					accountNumber: "1234567890",
					backgroundColor: "#EA6E2C",
					url: "",
					notes: ""
				)

				ServiceProvider.Draft(
					profileID: profileID,
					providerType: .cell,
					name: "T-Mobile",
					monthlyCost: 70,
					accountNumber: "",
					backgroundColor: "purple",
					url: "t-mobile.com",
					notes: ""
				)

				ServiceProvider.Draft(
					profileID: profileID,
					providerType: .tv,
					name: "YouTube TV",
					monthlyCost: 83,
					accountNumber: "",
					backgroundColor: "#E42C1F",
					url: "tv.youtube.com",
					notes: ""
				)

				Subscription.Draft(
					profileID: profileID,
					name: "Apple Music",
					category: .software,
					monthlyCost: 6,
					billingCycle: .monthly,
					renewalDate: .components(year: 2026, month: 5, day: 23),
					isActive: true,
					backgroundColor: "#7D9FE1",
					url: "music.apple.com",
					notes: ""
				)
			}
		}

		// MARK: - Career

		private func seedCareer(db: Database, profileID: Profile.ID) throws {
			try db.seed {
				Job.Draft(
					profileID: profileID,
					company: "TinyCorp",
					title: "Junior App Developer",
					startDate: .components(year: 2000, month: 1, day: 1),
					endDate: .components(year: 2021, month: 1, day: 1),
					isCurrent: false,
					salary: 70_000,
					employmentType: .fullTime,
					backgroundColor: "#FF1F00",
					notes: ""
				)

				Job.Draft(
					profileID: profileID,
					company: "SmallCorp",
					title: "App Developer",
					startDate: .components(year: 2021, month: 1, day: 1),
					endDate: .components(year: 2022, month: 1, day: 1),
					isCurrent: false,
					salary: 90_000,
					employmentType: .fullTime,
					backgroundColor: "#FF9200",
					notes: ""
				)

				Job.Draft(
					profileID: profileID,
					company: "MedCorp",
					title: "Senior App Developer",
					startDate: .components(year: 2022, month: 1, day: 1),
					endDate: .components(year: 2023, month: 1, day: 1),
					isCurrent: false,
					salary: 135_000,
					employmentType: .fullTime,
					backgroundColor: "#8A1DEB",
					notes: ""
				)

				Job.Draft(
					profileID: profileID,
					company: "MegaCorp",
					title: "Lead App Developer",
					startDate: .components(year: 2023, month: 1, day: 1),
					endDate: nil,
					isCurrent: true,
					salary: 200_000,
					employmentType: .fullTime,
					backgroundColor: "#D82CF4",
					notes: ""
				)
			}
		}
	}

	extension Date {
		fileprivate static func components(year: Int, month: Int, day: Int) -> Date {
			Calendar.current.date(
				from: DateComponents(year: year, month: month, day: day)
			) ?? Date()
		}
	}

#endif
