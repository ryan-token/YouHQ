//
//  SecondaryText.swift
//  YouHQ
//
//  Created by Ryan Token on 1/2/26.
//

import SwiftUI

struct SecondaryText: View {
	let text: String

	init(_ text: String) {
		self.text = text
	}

    var body: some View {
        Text(text)
			.foregroundStyle(.secondary)
    }
}

#Preview {
    SecondaryText("Secondary Text")
}
