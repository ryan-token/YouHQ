//
//  Constants.swift
//  YouHQ
//
//  Created by Ryan Token on 1/23/26.
//

import Foundation

struct Constants {
	// MARK: - Paywall
	static let paywallProfilesThreshold = 1
	static let paywallResidencesThreshold = 1
	static let paywallVehiclesThreshold = 1
	static let paywallCoreItemsThreshold = 5
	static let paywallMaintenanceItemsThreshold = 5
	static let paywallPaintColorsThreshold = 5

	// MARK: - Privacy Policy & Terms of Use
	static let privacyPolicyURL = URL(string: "https://www.ryantoken.com/privacy-policy")!
	static let termsOfUseURL = URL(string: "https://www.ryantoken.com/terms-of-use")!

	// MARK: - Other
	static let ryantokenURL = URL(string: "https://www.ryantoken.com")!
	static let telemetryDeckAPIKey = Bundle.main.infoDictionary?["TelemetryDeckAPIKey"] as? String ?? ""
}
