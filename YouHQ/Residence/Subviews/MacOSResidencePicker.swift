//
//  MacOSResidencePicker.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct MacOSResidencePicker: View {
	let residences: [Residence]
	@Binding var selectedResidenceID: String?

	var body: some View {
		#if os(macOS)
		if residences.count > 1 {
				Picker(
					"Choose Home",
					selection: $selectedResidenceID
				) {
					ForEach(residences) { residence in
						Text(
							residence.unitOrStreet
								?? residence.street
						)
						.tag(residence.id.uuidString)
					}
				}
				.labelsHidden()
			}
		#endif
	}
}

#Preview {
	MacOSResidencePicker(residences: [], selectedResidenceID: .constant(UUID().uuidString))
}
