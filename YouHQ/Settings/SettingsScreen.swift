//
//  SettingsScreen.swift
//  YouHQ
//
//  Created by Ryan Token on 1/25/26.
//

import SwiftUI

struct SettingsScreen: View {
	enum SettingsTab {
		case general, profiles
	}

	@State private var selectedTab: SettingsTab = .general

	var body: some View {
		#if os(macOS)
			NavigationSplitView {
				List(selection: $selectedTab) {
					Label("General", systemImage: "gear")
						.tag(SettingsTab.general)
					Label("Profiles", systemImage: "person.crop.circle")
						.tag(SettingsTab.profiles)
				}
				.listStyle(.sidebar)
				.navigationSplitViewColumnWidth(200)
			} detail: {
				Group {
					switch selectedTab {
					case .general:
						GeneralSettingsView()
					case .profiles:
						EmptyView()
					}
				}
				.frame(maxHeight: .infinity, alignment: .top)
				.navigationSplitViewColumnWidth(min: 100, ideal: 100)
			}
		#else
			// iOS version without selection binding
			NavigationSplitView {
				List {
					NavigationLink(value: SettingsTab.general) {
						Label("General", systemImage: "gear")
					}
					NavigationLink(value: SettingsTab.profiles) {
						Label("Profiles", systemImage: "person.crop.circle")
					}
				}
				.listStyle(.sidebar)
				.navigationTitle("Settings")
			} detail: {
				NavigationStack {
					Group {
						switch selectedTab {
						case .general:
							GeneralSettingsView()
						case .profiles:
							EmptyView()
						}
					}
				}
			}
		#endif
	}
}

#Preview {
	SettingsScreen()
}
