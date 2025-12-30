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
	init() {
		prepareDependencies {
			try! $0.bootstrapDatabase()
		}
	}

	var body: some Scene {
		WindowGroup {
			AppEntryPoint()
		}
	}
}
