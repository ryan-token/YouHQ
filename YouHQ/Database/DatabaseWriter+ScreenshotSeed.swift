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
		///
		/// Every company name is made up, so the store listing shows no third-party trademarks.
		/// Due dates are relative to today, so each maintenance item stays in the same section.
		///
		/// - Returns: The "App Store" profile and the residence the Home tab should open to.
		@discardableResult
		func seedScreenshotData() throws -> (profileID: Profile.ID, residenceID: Residence.ID) {
			let appStoreProfileID = UUID()
			let denverID = UUID()

			try write { db in
				// Delete every profile — cascades delete all children.
				try Profile.delete().execute(db)

				let morrisonID = UUID()
				let civicID = UUID()
				let renegadeID = UUID()
				let now = Date.now

				try db.seed {
					Profile.Draft(
						id: appStoreProfileID,
						name: "App Store",
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

			return (appStoreProfileID, denverID)
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
					moveInDate: .components(year: 2021, month: 6, day: 1),
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
					provider: "Front Range Energy",
					accountNumber: "4810 2273 9065",
					approximateMonthlyCost: 75,
					backgroundColor: "#F6D045",
					url: "",
					notes: ""
				)

				Utility.Draft(
					residenceID: denverID,
					type: .gas,
					provider: "Front Range Energy",
					accountNumber: "4810 2273 9188",
					approximateMonthlyCost: 70,
					backgroundColor: "#3783EF",
					url: "",
					notes: "Front Range handles both electric and gas."
				)

				InsurancePolicy.Draft(
					profileID: profileID,
					residenceID: denverID,
					vehicleID: nil,
					type: .renters,
					provider: "Summit Mutual",
					policyNumber: "RN-5528-0193",
					monthlyCost: 18,
					deductible: 500,
					coverageAmount: 40_000,
					startDate: nil,
					renewalDate: .daysFromNow(74),
					isActive: true,
					backgroundColor: "teal",
					url: "",
					notes: ""
				)

				PaintColor.Draft(
					profileID: profileID,
					residenceID: denverID,
					vehicleID: nil,
					manufacturer: "Ridgeline Paints",
					colorName: "Morning Fog",
					colorCode: "RP-1124",
					room: "Living Room",
					finish: .eggshell,
					purchaseDate: nil,
					surfaceType: "Walls",
					storePurchasedFrom: "",
					applicationDate: nil,
					backgroundColor: "gray",
					notes: ""
				)

				PaintColor.Draft(
					profileID: profileID,
					residenceID: denverID,
					vehicleID: nil,
					manufacturer: "Ridgeline Paints",
					colorName: "Sage Meadow",
					colorCode: "RP-2307",
					room: "Kitchen",
					finish: .satin,
					purchaseDate: nil,
					surfaceType: "Cabinets",
					storePurchasedFrom: "",
					applicationDate: nil,
					backgroundColor: "green",
					notes: ""
				)

				MaintenanceItem.Draft(
					profileID: profileID,
					residenceID: denverID,
					vehicleID: nil,
					name: "Replace HVAC Filter",
					itemDescription: "",
					intervalType: .month,
					intervalValue: 3,
					lastCompletedAt: nil,
					dueDate: .daysFromNow(-3),
					shouldNotify: true,
					notificationIdentifier: "",
					notes: ""
				)

				MaintenanceItem.Draft(
					profileID: profileID,
					residenceID: denverID,
					vehicleID: nil,
					name: "Test Smoke Detectors",
					itemDescription: "",
					intervalType: .month,
					intervalValue: 6,
					lastCompletedAt: nil,
					dueDate: .daysFromNow(9),
					shouldNotify: true,
					notificationIdentifier: "",
					notes: ""
				)

				MaintenanceItem.Draft(
					profileID: profileID,
					residenceID: denverID,
					vehicleID: nil,
					name: "Clean Gutters",
					itemDescription: "",
					intervalType: .year,
					intervalValue: 1,
					lastCompletedAt: nil,
					dueDate: .daysFromNow(21),
					shouldNotify: true,
					notificationIdentifier: "",
					notes: ""
				)

				MaintenanceItem.Draft(
					profileID: profileID,
					residenceID: denverID,
					vehicleID: nil,
					name: "Flush Water Heater",
					itemDescription: "",
					intervalType: .year,
					intervalValue: 1,
					lastCompletedAt: nil,
					dueDate: .daysFromNow(120),
					shouldNotify: true,
					notificationIdentifier: "",
					notes: ""
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
					provider: "Summit Mutual",
					policyNumber: "AU-7731-4402",
					monthlyCost: 179,
					deductible: 1000,
					coverageAmount: nil,
					startDate: nil,
					renewalDate: .daysFromNow(74),
					isActive: true,
					backgroundColor: "red",
					url: "",
					notes: ""
				)

				PaintColor.Draft(
					profileID: profileID,
					residenceID: nil,
					vehicleID: civicID,
					manufacturer: "",
					colorName: "Aegean Blue Metallic",
					colorCode: "B-593M",
					room: "Exterior",
					finish: .gloss,
					purchaseDate: nil,
					surfaceType: "Exterior",
					storePurchasedFrom: "",
					applicationDate: nil,
					notes: ""
				)

				MaintenanceItem.Draft(
					profileID: profileID,
					residenceID: nil,
					vehicleID: civicID,
					name: "Oil Change",
					itemDescription: "",
					intervalType: .month,
					intervalValue: 6,
					lastCompletedAt: nil,
					dueDate: .daysFromNow(12),
					shouldNotify: true,
					notificationIdentifier: "",
					notes: ""
				)

				MaintenanceItem.Draft(
					profileID: profileID,
					residenceID: nil,
					vehicleID: civicID,
					name: "Tire Rotation",
					itemDescription: "",
					intervalType: .month,
					intervalValue: 6,
					lastCompletedAt: nil,
					dueDate: .daysFromNow(40),
					shouldNotify: true,
					notificationIdentifier: "",
					notes: ""
				)

				MaintenanceItem.Draft(
					profileID: profileID,
					residenceID: nil,
					vehicleID: civicID,
					name: "Replace Wiper Blades",
					itemDescription: "",
					intervalType: .year,
					intervalValue: 1,
					lastCompletedAt: nil,
					dueDate: .daysFromNow(95),
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
					bankName: "Harbor Bank",
					accountType: .checking,
					accountNumber: "7302 1948 56",
					routingNumber: "102 938 475",
					isActive: true,
					backgroundColor: "#6E1FA2",
					url: "",
					notes: ""
				)

				BankAccount.Draft(
					profileID: profileID,
					bankName: "Clearwater Savings",
					accountType: .savings,
					accountNumber: "5521 8830 17",
					routingNumber: "",
					isActive: true,
					backgroundColor: "#E0B979",
					url: "",
					notes: ""
				)

				InvestmentAccount.Draft(
					profileID: profileID,
					institution: "Evergreen Investments",
					accountType: .brokerage,
					accountNumber: "EV-2216-0847",
					isActive: true,
					backgroundColor: "#4394E5",
					url: "",
					notes: ""
				)

				HealthSavingsAccount.Draft(
					profileID: profileID,
					accountType: .hsa,
					institution: "Meridian Health",
					accountNumber: "HS-6604-3192",
					isActive: true,
					backgroundColor: "#438E93",
					url: "",
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
					name: "Peak Fiber",
					monthlyCost: 66,
					accountNumber: "PF-80203-114",
					backgroundColor: "#EA6E2C",
					url: "",
					notes: ""
				)

				ServiceProvider.Draft(
					profileID: profileID,
					providerType: .cell,
					name: "Brightwave Wireless",
					monthlyCost: 70,
					accountNumber: "",
					backgroundColor: "purple",
					url: "",
					notes: ""
				)

				ServiceProvider.Draft(
					profileID: profileID,
					providerType: .tv,
					name: "Streamline TV",
					monthlyCost: 83,
					accountNumber: "",
					backgroundColor: "#E42C1F",
					url: "",
					notes: ""
				)

				Subscription.Draft(
					profileID: profileID,
					name: "Encore Music",
					category: .music,
					monthlyCost: 11,
					billingCycle: .monthly,
					renewalDate: .daysFromNow(8),
					isActive: true,
					backgroundColor: "#7D9FE1",
					url: "",
					notes: ""
				)

				Subscription.Draft(
					profileID: profileID,
					name: "Skyvault Storage",
					category: .cloud,
					monthlyCost: 3,
					billingCycle: .monthly,
					renewalDate: .daysFromNow(17),
					isActive: true,
					backgroundColor: "#34AADC",
					url: "",
					notes: ""
				)

				Device.Draft(
					profileID: profileID,
					type: .computer,
					brand: "Nimbus",
					model: "Air 14",
					serialNumber: "NB14-7Q2K-93XD",
					purchaseDate: .components(year: 2024, month: 9, day: 14),
					backgroundColor: "#5E5CE6",
					url: "",
					notes: ""
				)

				Device.Draft(
					profileID: profileID,
					type: .tv,
					brand: "Vistara",
					model: "65-inch 4K",
					serialNumber: "VS65-4K-20817",
					purchaseDate: .components(year: 2023, month: 11, day: 24),
					backgroundColor: "#FF6482",
					url: "",
					notes: ""
				)
			}
		}

		// MARK: - Career

		private func seedCareer(db: Database, profileID: Profile.ID) throws {
			try db.seed {
				Job.Draft(
					profileID: profileID,
					company: "Birch",
					title: "Junior App Developer",
					startDate: .components(year: 2016, month: 6, day: 1),
					endDate: .components(year: 2018, month: 8, day: 1),
					isCurrent: false,
					salary: 70_000,
					employmentType: .fullTime,
					backgroundColor: "#FF1F00",
					notes: ""
				)

				Job.Draft(
					profileID: profileID,
					company: "Lumen",
					title: "App Developer",
					startDate: .components(year: 2018, month: 9, day: 1),
					endDate: .components(year: 2021, month: 3, day: 1),
					isCurrent: false,
					salary: 90_000,
					employmentType: .fullTime,
					backgroundColor: "#FF9200",
					notes: ""
				)

				Job.Draft(
					profileID: profileID,
					company: "Tidal",
					title: "Senior App Developer",
					startDate: .components(year: 2021, month: 4, day: 1),
					endDate: .components(year: 2023, month: 12, day: 1),
					isCurrent: false,
					salary: 135_000,
					employmentType: .fullTime,
					backgroundColor: "#8A1DEB",
					notes: ""
				)

				Job.Draft(
					profileID: profileID,
					company: "Cascade",
					title: "Lead App Developer",
					startDate: .components(year: 2024, month: 1, day: 8),
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
			) ?? Date.now
		}

		fileprivate static func daysFromNow(_ days: Int) -> Date {
			Calendar.current.date(byAdding: .day, value: days, to: .now) ?? .now
		}
	}

#endif
