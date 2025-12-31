//
//  YouHQApp.swift
//  YouHQ
//
//  Created by Ryan Token on 12/29/25.
//

import Dependencies
import SwiftUI

@main
struct YouHQApp: App {
	@Dependency(\.context) var context

	init() {
		if context == .live {
			prepareDependencies {
				try! $0.bootstrapDatabase()
			}
		}
	}

	var body: some Scene {
		WindowGroup {
			AppEntryPoint()
		}
	}
}
