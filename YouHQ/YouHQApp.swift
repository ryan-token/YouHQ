//
//  YouHQApp.swift
//  YouHQ
//
//  Created by Ryan Token on 12/29/25.
//

import Dependencies
import SQLiteData
import SwiftUI
import TelemetryDeck
import UserNotifications

@main
struct YouHQApp: App {
	@Dependency(\.context) var context
	@Environment(\.scenePhase) private var scenePhase
	@State private var paywallManager = PaywallManager()

	#if !os(macOS)
		@UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
	#endif

	init() {
		if context == .live {
			initializeSQLiteData()
			TelemetryDeck.initialize(config: .init(appID: Constants.telemetryDeckAPIKey))
		}
	}

	var body: some Scene {
		WindowGroup {
			AppEntryPoint()
				.environment(paywallManager)
				.task(id: scenePhase) {
					await paywallManager.setup()
					await refreshNotifications()
				}

				#if os(macOS)
					.frame(
						minWidth: 600,
						idealWidth: 800,
						maxWidth: .infinity,
						minHeight: 500,
						idealHeight: 500,
						maxHeight: .infinity
					)
				#endif
		}
		#if os(macOS)
			.windowResizability(.contentSize)
		#endif

		#if os(macOS)
			Settings {
				SettingsScreen()
					.environment(paywallManager)
					.task { await paywallManager.setup() }
					.frame(
						minWidth: 600,
						idealWidth: 800,
						maxWidth: .infinity,
						minHeight: 500,
						idealHeight: 500,
						maxHeight: .infinity
					)
			}
		#endif
	}

	private func initializeSQLiteData() {
		try! prepareDependencies { // swiftlint:disable:this force_try
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
				InsurancePolicy.self,
				MaintenanceItem.self,
				MaintenanceCompletion.self,
				PaintColor.self,
				Other.self,
				Asset.self
			)
		}
	}

	private func refreshNotifications() async {
		// Only refresh when becoming active (includes initial launch)
		guard scenePhase == .active else { return }

		let status = await NotificationManager.shared.checkAuthorizationStatus()
		if status == .authorized {
			await NotificationManager.shared.refreshAllNotifications()
		}
	}
}
