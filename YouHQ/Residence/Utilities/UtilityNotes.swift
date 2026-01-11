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
		VStack(alignment: .leading, spacing: 0) {
			Text("Notes:")
				.fontWeight(.semibold)

			TextEditor(text: $notes)
				.textEditorOnColor()
				#if os(macOS)
					.padding(.top, 8)
				#endif
		}
		.foregroundStyle(.white)
	}
}

#Preview {
	UtilityNotes(notes: .constant("Some notes"))
}
