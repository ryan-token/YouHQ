//
//  AddMoreButtonLabel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/26/26.
//

import SwiftUI

struct AddMoreButtonLabel: View {
	let text: String
	let backgroundColor: Color?

	init(text: String, backgroundColor: Color? = nil) {
		self.text = text
		self.backgroundColor = backgroundColor
	}

	var body: some View {
		HStack {
			Image(systemName: "plus.circle.fill")
				.font(.title2)
			HQText(text)
				.font(.headline)
		}
		.frame(maxWidth: .infinity)
		.padding()
		.background {
			if let backgroundColor {
				backgroundColor
			} else {
				Rectangle().fill(.ultraThinMaterial)
			}
		}
		.foregroundStyle(backgroundColor == nil ? AnyShapeStyle(.primary) : AnyShapeStyle(Color.white))
		.clipShape(.rect(cornerRadius: 12))
	}
}

#Preview {
	AddMoreButtonLabel(text: "Add More")
}
