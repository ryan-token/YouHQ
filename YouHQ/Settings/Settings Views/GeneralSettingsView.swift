//
//  GeneralSettingsView.swift
//  YouHQ
//
//  Created by Ryan Token on 1/25/26.
//

import SwiftUI

struct GeneralSettingsView: View {
	@AppStorage("hidePrivateInfo") private var hidePrivateInfo = true

	var body: some View {
		Form {
			Section {
				Toggle("Hide Private Info (costs, accounts numbers, salaries)", isOn: $hidePrivateInfo)
			}
		}
		.formStyle(.grouped)
		.navigationTitle("General")
		#if !os(macOS)
			.navigationBarTitleDisplayMode(.inline)
		#endif
	}
}

#Preview {
	GeneralSettingsView()
}
