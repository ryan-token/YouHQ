//
//  ResidenceEdit+DatesSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/3/26.
//

import SwiftUI

extension ResidenceEdit {
	struct DatesSection: View {
		@Bindable var vm: ResidenceEdit.ViewModel

		var body: some View {
			Section("Dates") {
				DatePicker(
					"Move-In Date",
					selection: Binding(
						get: { vm.moveInDate ?? Date() },
						set: { vm.moveInDate = $0 }
					),
					displayedComponents: .date
				)

				DatePicker(
					"Move-Out Date",
					selection: Binding(
						get: { vm.moveOutDate ?? Date() },
						set: { vm.moveOutDate = $0 }
					),
					displayedComponents: .date
				)
			}
		}
	}
}

#Preview {
	Form {
		ResidenceEdit.DatesSection(
			vm: ResidenceEdit.ViewModel(
				residence: nil,
				profileID: UUID()
			)
		)
	}
}
