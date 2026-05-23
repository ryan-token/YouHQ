//
//  MacOSResidencePicker.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct MacOSResidencePicker: View {
	let residences: [Residence]
	@Binding var selectedResidence: Residence?

	var body: some View {
		#if os(macOS)
			if residences.count > 1 {
				Picker(
					"Choose Home",
					selection: $selectedResidence
				) {
					ForEach(residences) { residence in
						HQText(
							residence.unitOrStreet
								?? residence.street
						)
						.tag(residence as Residence?)
					}
				}
				.labelsHidden()
			}
		#endif
	}
}

#Preview {
	MacOSResidencePicker(residences: [], selectedResidence: .constant(nil))
}
