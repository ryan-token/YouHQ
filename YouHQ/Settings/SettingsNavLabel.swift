//
//  SettingsNavLabel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/25/26.
//

import SwiftUI

struct SettingsNavLabel: View {
	let labelText: String
	let iconName: String
	let iconColor: Color

	var body: some View {
		HStack {
			Label {
				Text(labelText)
			} icon: {
				Image(systemName: iconName)
					.rowIcon(color: iconColor)
			}

			#if !os(macOS)
				Spacer()

				Image(systemName: "chevron.forward")
					.foregroundStyle(.secondary)
					.font(.caption)
					.fontWeight(.semibold)
			#endif
		}
	}
}

#Preview {
	SettingsNavLabel(
		labelText: "General",
		iconName: "square.stack.fill",
		iconColor: .gray
	)
}
