//
//  AddMoreButtonLabel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/26/26.
//

import SwiftUI

struct AddMoreButtonLabel: View {
	let text: String

    var body: some View {
		HStack {
			Image(systemName: "plus.circle.fill")
				.font(.title2)
			Text(text)
				.font(.headline)
		}
		.frame(maxWidth: .infinity)
		.padding()
		.background(.ultraThinMaterial)
		.clipShape(.rect(cornerRadius: 12))
    }
}

#Preview {
    AddMoreButtonLabel(text: "Add More")
}
