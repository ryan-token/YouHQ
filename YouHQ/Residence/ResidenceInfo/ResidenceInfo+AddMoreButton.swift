//
//  ResidenceInfo+AddMoreButton.swift
//  YouHQ
//
//  Created by Ryan Token on 1/10/26.
//

import SwiftUI

extension ResidenceInfo {
	struct AddMoreButton: View {
		let vm: ResidenceScreen.ViewModel

		var body: some View {
			Menu {
				ResidenceMenu(vm: vm, includeAddResidence: false)
			} label: {
				HStack {
					Image(systemName: "plus.circle.fill")
						.font(.title2)
					Text("Add More")
						.font(.headline)
				}
				.frame(maxWidth: .infinity)
				.padding()
				.background(.ultraThinMaterial)
				.clipShape(.rect(cornerRadius: 12))
			}
			.buttonStyle(.plain)
			.padding(.bottom)
		}
	}
}

#Preview {
	ResidenceInfo.AddMoreButton(vm: ResidenceScreen.ViewModel())
}
