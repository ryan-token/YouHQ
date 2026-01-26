//
//  ProfileSettingsView.swift
//  YouHQ
//
//  Created by Ryan Token on 1/25/26.
//

import SwiftUI

struct ProfileSettingsView: View {
	var body: some View {
		Form {
			Section {
				Text("Profiles")
			}
		}
		.formStyle(.grouped)
		.navigationTitle("Profiles")
		#if !os(macOS)
			.navigationBarTitleDisplayMode(.inline)
		#endif
	}
}

#Preview {
	ProfileSettingsView()
}
