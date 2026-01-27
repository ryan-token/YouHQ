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
				AddMoreButtonLabel(text: "Add More")
			}
			.buttonStyle(.plain)
			.padding(.bottom)
		}
	}
}

#Preview {
	CareerScreen.AddMoreButton(vm: CareerScreen.ViewModel())
}
