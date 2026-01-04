//
//  YouHQApp.swift
//  YouHQ
//
//  Created by Ryan Token on 12/29/25.
//

import Dependencies
import SQLiteData
import SwiftUI

@main
struct YouHQApp: App {
	@Dependency(\.context) var context

	init() {
		if context == .live {
			try! prepareDependencies {
				try $0.bootstrapDatabase()
				$0.defaultSyncEngine = try SyncEngine(
					for: $0.defaultDatabase,
					tables:
						Profile.self,
						Residence.self,
						Utility.self,
						Vehicle.self,
						BankAccount.self,
						InvestmentAccount.self,
						HealthSavingsAccount.self,
						ServiceProvider.self,
						Device.self,
						Subscription.self,
						Job.self,
						InsurancePolicy.self
				)
			}
		}
	}

	var body: some Scene {
		WindowGroup {
			AppEntryPoint()
		}
	}
}
