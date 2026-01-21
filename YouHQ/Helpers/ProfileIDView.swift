//
//  ProfileIDView.swift
//  YouHQ
//
//  Created by Ryan Token on 1/19/26.
//

import SwiftUI

struct ProfileIDView: View {
	let profileID: UUID?

	var body: some View {
		Group {
			if let profileID {
				Text("Selected Profile ID: \(profileID)")
			} else {
				Text("Selected Profile ID: nil")
			}
		}
		.font(.caption)
		.frame(maxWidth: .infinity, alignment: .leading)
		.listRowSeparator(.hidden)
	}
}

#Preview {
	ProfileIDView(profileID: UUID())
}
