//
//  AppDelegate.swift
//  YouHQ
//
//  Created by Ryan Token on 1/19/26.
//

import CloudKit
import Dependencies
import SQLiteData

#if canImport(UIKit)
	import UIKit

	class AppDelegate: UIResponder, UIApplicationDelegate {
		func application(
			_ application: UIApplication,
			configurationForConnecting connectingSceneSession: UISceneSession,
			options: UIScene.ConnectionOptions
		) -> UISceneConfiguration {
			let configuration = UISceneConfiguration(
				name: "Default Configuration",
				sessionRole: connectingSceneSession.role
			)
			configuration.delegateClass = SceneDelegate.self
			return configuration
		}
	}

	class SceneDelegate: UIResponder, UIWindowSceneDelegate {
		@Dependency(\.defaultSyncEngine) var syncEngine
		var window: UIWindow?

		func windowScene(
			_ windowScene: UIWindowScene,
			userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata
		) {
			Task {
				try await syncEngine.acceptShare(metadata: cloudKitShareMetadata)
			}
		}

		func scene(
			_ scene: UIScene,
			willConnectTo session: UISceneSession,
			options connectionOptions: UIScene.ConnectionOptions
		) {
			guard let cloudKitShareMetadata = connectionOptions.cloudKitShareMetadata else { return }
			Task {
				try await syncEngine.acceptShare(metadata: cloudKitShareMetadata)
			}
		}
	}

#elseif canImport(AppKit)
	import AppKit

	class AppDelegate: NSObject, NSApplicationDelegate {
		@Dependency(\.defaultSyncEngine) var syncEngine

		func application(
			_ application: NSApplication,
			userDidAcceptCloudKitShareWith metadata: CKShare.Metadata
		) {
			Task {
				try await syncEngine.acceptShare(metadata: metadata)
			}
		}
	}
#endif
