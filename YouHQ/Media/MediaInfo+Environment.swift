//
//  MediaInfo+Environment.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import SwiftUI

extension EnvironmentValues {
	/// Whether the Media tab blurs costs. Read by each Media row, so toggling it updates the
	/// rows without rebuilding the list that hosts them.
	@Entry var hideMediaCosts = false
}
