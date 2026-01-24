//
//  SelectedProfileIDView.swift
//  YouHQ
//
//  Created by Ryan Token on 1/19/26.
//

import SwiftUI

struct SelectedProfileIDView: View {
	let selectedProfileID: UUID?

	init(for selectedProfileID: UUID?) {
		self.selectedProfileID = selectedProfileID
	}

	var body: some View {
		Group {
			if let selectedProfileID {
				Text("Selected Profile ID: \(selectedProfileID)")
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
	SelectedProfileIDView(for: UUID())
}
