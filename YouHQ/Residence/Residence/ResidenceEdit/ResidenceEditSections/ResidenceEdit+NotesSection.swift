//
//  ResidenceEdit+NotesSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/3/26.
//

import SwiftUI

extension ResidenceEdit {
	struct NotesSection: View {
		@Bindable var vm: ResidenceEdit.ViewModel

		var body: some View {
			Section("Notes") {
				TextEditor(text: $vm.notes)
					.frame(minHeight: 100)
			}
		}
	}
}

#Preview {
	Form {
		ResidenceEdit.NotesSection(
			vm: ResidenceEdit.ViewModel(
				residence: nil,
				profileID: UUID()
			)
		)
	}
}
