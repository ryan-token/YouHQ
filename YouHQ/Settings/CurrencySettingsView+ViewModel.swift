//
//  CurrencySettingsView+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 6/9/26.
//

import Dependencies
import SQLiteData
import SwiftUI

extension CurrencySettingsView {
	@Observable
	final class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) private var database

		/// The app-wide default currency code. `nil` means "follow the device
		/// locale".
		var selectedCode: String?

		private var appSettingsID: UUID?

		func load() async {
			withErrorReporting {
				let settings = try database.read { db in
					try AppSettings.fetchAll(db).first
				}
				if let settings {
					appSettingsID = settings.id
					selectedCode = settings.currencyCode
				}
			}
		}

		func select(_ code: String?) {
			selectedCode = code
			guard let appSettingsID else { return }
			withErrorReporting {
				try database.write { db in
					try AppSettings.find(appSettingsID)
						.update { $0.currencyCode = code }
						.execute(db)
				}
			}
		}
	}
}
