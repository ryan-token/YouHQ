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
		.if(backgroundColor != nil) {
			$0.background(backgroundColor)
		}
		.if(backgroundColor != nil) {
			$0.foregroundStyle(.white)
		}
		.if(backgroundColor == nil) {
			$0.background(.ultraThinMaterial)
		}
		.clipShape(.rect(cornerRadius: 12))
	}
}

#Preview {
	AddMoreButtonLabel(text: "Add More")
}
