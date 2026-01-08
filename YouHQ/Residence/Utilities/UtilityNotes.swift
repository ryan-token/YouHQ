//
//  UtilityNotes.swift
//  YouHQ
//
//  Created by Ryan Token on 1/7/26.
//

import SwiftUI

struct UtilityNotes: View {
	@Binding var notes: String

	var body: some View {
		VStack(alignment: .leading) {
			Text("Notes:")
				.fontWeight(.semibold)

			TextEditor(text: $notes)
				.textSelection(.enabled)
				.frame(minHeight: 40)
		}
		.foregroundStyle(.white)
	}
}

#Preview {
	UtilityNotes(notes: .constant("Some notes"))
}
