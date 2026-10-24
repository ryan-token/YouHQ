//
//  MediaInfo+Environment.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import SwiftUI

extension EnvironmentValues {
	/// Whether the Media tab blurs costs. Only the rows that show a cost read it, so toggling it
	/// skips `MediaInfo` and the device rows.
	@Entry var hideMediaCosts = false
}
