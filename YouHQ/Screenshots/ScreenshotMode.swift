//
//  ScreenshotMode.swift
//  YouHQ
//
//  Created by Ryan Token on 10/23/26.
//

#if DEBUG

	import Foundation
	import SQLiteData
	import SwiftUI

	/// Debug-only launch arguments for App Store screenshots.
	///
	/// `-ScreenshotMode` runs the app against a scratch database of sample data with iCloud sync
	/// stopped, and skips launch-time side effects. The user's own database, iCloud data and
	/// settings are never touched.
	///
	/// - `-ScreenshotTab <home|vehicles|money|media|career>` opens a tab.
	/// - `-ScreenshotScreen maintenance` opens the Home tab's maintenance items.
	/// - `-ScreenshotAppearance dark` forces dark mode, for macOS, where `simctl` can't set it.
	enum ScreenshotMode {
		static let isEnabled = ProcessInfo.processInfo.arguments.contains("-ScreenshotMode")

		static let tab: AppTabView.AppTab? = argument("-ScreenshotTab").flatMap { name in
			let tab = AppTabView.AppTab(rawValue: name)
			if tab == nil { print("⚠️ ScreenshotMode: unknown tab \"\(name)\"") }
			return tab
		}

		static let opensMaintenanceItems = argument("-ScreenshotScreen") == "maintenance"

		static let colorScheme: ColorScheme? = argument("-ScreenshotAppearance") == "dark" ? .dark : nil

		/// Opens and seeds the scratch database, then points the app's stored selections at it.
		static func prepare() {
			do {
				let databasePath = URL.temporaryDirectory
					.appending(path: "YouHQ-Screenshots.sqlite")
					.path(percentEncoded: false)
				var seeded: (profileID: Profile.ID, residenceID: Residence.ID)?

				try prepareDependencies {
					$0.defaultDatabase = try appDatabase(path: databasePath)
					seeded = try $0.defaultDatabase.seedScreenshotData()
					// Views read the sync engine's state; never starting it keeps the sample data off iCloud.
					$0.defaultSyncEngine = try SyncEngine(
						for: $0.defaultDatabase,
						tables: Profile.self,
						startImmediately: false
					)
				}

				if let seeded {
					setLaunchDefaults([
						"hasLaunchedApp": true,
						.selectedProfileIDKey: seeded.profileID.uuidString,
						"selectedResidenceID": seeded.residenceID.uuidString
					])
				}
			} catch {
				fatalError("Screenshot mode setup failed: \(error)")
			}
		}

		/// Overrides `values` for this launch only. The argument domain is never written to disk, so
		/// the user's own settings come back on the next normal launch.
		private static func setLaunchDefaults(_ values: [String: Any]) {
			let defaults = UserDefaults.standard
			let arguments = defaults.volatileDomain(forName: UserDefaults.argumentDomain)
			defaults.setVolatileDomain(
				arguments.merging(values) { _, new in new },
				forName: UserDefaults.argumentDomain
			)
		}

		/// The value after a launch argument such as `-ScreenshotTab money`.
		private static func argument(_ flag: String) -> String? {
			let arguments = ProcessInfo.processInfo.arguments
			guard let index = arguments.firstIndex(of: flag), arguments.indices.contains(index + 1) else {
				return nil
			}
			return arguments[index + 1]
		}
	}

#endif
