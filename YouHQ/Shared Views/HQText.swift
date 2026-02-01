//
//  HQText.swift
//  YouHQ
//
//  Created by Ryan Token on 1/31/26.
//

import SwiftUI

struct HQText: View {
	let text: String

	init(_ text: String) {
		self.text = text
	}

	var body: some View {
		Text(text)
			.fontDesign(.rounded)
	}
}

#Preview {
	HQText("YouHQ Premium")
}
