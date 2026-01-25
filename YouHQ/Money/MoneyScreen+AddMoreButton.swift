//
//  MoneyScreen+AddMoreButton.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

extension MoneyScreen {
	struct AddMoreButton: View {
		let vm: ViewModel

		var body: some View {
			Menu {
				MoneyMenu(vm: vm)
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
