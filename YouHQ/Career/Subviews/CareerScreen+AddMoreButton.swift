//
//  CareerScreen+AddMoreButton.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

extension CareerScreen {
	struct AddMoreButton: View {
		let vm: ViewModel

		var body: some View {
			Menu {
				CareerMenu(vm: vm)
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
	CareerScreen.AddMoreButton(vm: CareerScreen.ViewModel())
}
