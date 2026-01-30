//
//  YouHQPremiumView.swift
//  YouHQ
//
//  Created by Ryan Token on 1/25/26.
//

import SwiftUI

struct YouHQPremiumView: View {
	var body: some View {
		Form {
			Section {
				Text("Premium")
			}
		}
		.formStyle(.grouped)
		.navigationTitle("YouHQ Premium")
		#if !os(macOS)
			.navigationBarTitleDisplayMode(.inline)
		#endif
	}
}

#Preview {
	YouHQPremiumView()
}
