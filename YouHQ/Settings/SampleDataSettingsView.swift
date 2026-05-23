//
//  SampleDataSettingsView.swift
//  YouHQ
//

#if DEBUG

	import Dependencies
	import SQLiteData
	import Sharing
	import SwiftUI

	struct SampleDataSettingsView: View {
		@Dependency(\.defaultDatabase) private var database
		@Shared(.appStorage(.selectedProfileIDKey)) private var selectedProfileIDString = ""

		@State private var isShowingConfirmation = false
		@State private var seedResultMessage: String?

		var body: some View {
			List {
				Section {
					Button {
						isShowingConfirmation = true
					} label: {
						AddMoreButtonLabel(
							text: "Seed App Store Sample Data",
							backgroundColor: .indigo
						)
					}
					.buttonStyle(.plain)
					.listRowBackground(Color.clear)

					if let seedResultMessage {
						HQText(seedResultMessage)
							.foregroundStyle(.secondary)
							.listRowBackground(Color.clear)
					}
				}

				VStack(alignment: .leading, spacing: 12) {
					Text(
						"""
						**Wipes all profiles and data**, then inserts a canonical \
						sample data set used for App Store screenshots.
						"""
					)

					Text("Two profiles are created: **App Store** (populated) and **Ryan** (empty).")

					Text("This option is only available in debug builds.")
				}
				.fontDesign(.rounded)
				.foregroundStyle(.secondary)
				.listRowBackground(Color.clear)
				.listRowSeparator(.hidden)
				.padding(.top)
			}
			.contentMargins(.top, 0)
			.navigationTitle("Sample Data")
			#if !os(macOS)
				.navigationBarTitleDisplayMode(.inline)
			#endif
			.alert(
				"Replace all data?",
				isPresented: $isShowingConfirmation
			) {
				Button("Replace with Sample Data", role: .destructive) {
					seedSampleData()
				}
				Button("Cancel", role: .cancel) {}
			} message: {
				HQText(
					"""
					This deletes every profile and all of its data, \
					then inserts the App Store screenshot sample data. \
					This cannot be undone.
					"""
				)
			}
		}

		private func seedSampleData() {
			withErrorReporting {
				try database.seedScreenshotData()

				let appStoreProfile = try database.read { db in
					try Profile
						.where { $0.name.eq("App Store") }
						.fetchOne(db)
				}

				if let appStoreProfile {
					$selectedProfileIDString.withLock {
						$0 = appStoreProfile.id.uuidString
					}
					notifyProfileChanged()
				}

				seedResultMessage = "✅ Sample data seeded."
			}
		}
	}

	#Preview {
		NavigationStack {
			SampleDataSettingsView()
		}
	}

#endif
