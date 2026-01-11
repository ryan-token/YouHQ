//
//  InsuranceNotes.swift
//  YouHQ
//
//  Created by Ryan Token on 1/11/26.
//

import SwiftUI

struct InsuranceNotes: View {
	@Binding var notes: String

	var body: some View {
		if notes.isNotEmpty {
			VStack(alignment: .leading, spacing: 4) {
				Text("Notes:")
					.font(.headline)
					.foregroundStyle(.white)
				Text(notes)
					.foregroundStyle(.white)
			}
		}
	}
}

#Preview {
	@Previewable @State var notes = "Comprehensive coverage with flood insurance"
	InsuranceNotes(notes: $notes)
}
