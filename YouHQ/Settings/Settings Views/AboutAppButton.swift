//
//  AboutAppButton.swift
//  YouHQ
//
//  Created by Ryan Token on 1/25/26.
//

import SwiftUI

struct AboutAppButton: View {
    var body: some View {
		Button {
			// TODO: Show About Sheet
			print("Show about sheet")
		} label: {
			HStack {
				Label {
					Text("About")
				} icon: {
					Image(systemName: "person.crop.square.fill")
						.font(.title3)
						.foregroundStyle(.blue)
				}

				Spacer()
			}
			.contentShape(.rect)
		}
		.buttonStyle(.plain)
    }
}
#Preview {
    AboutAppButton()
}
