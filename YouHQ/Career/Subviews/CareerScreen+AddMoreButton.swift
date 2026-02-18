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
		@Environment(\.sheetNamespace) private var namespace

		var body: some View {
			Menu {
				CareerMenu(vm: vm, sourceID: "addMoreButton")
			} label: {
				AddMoreButtonLabel(text: "Add More")
			}
			.buttonStyle(.plain)
			.padding(.bottom)
			.matchedTransitionSource(id: "addMoreButton", in: namespace)
		}
	}
}

#Preview {
	CareerScreen.AddMoreButton(vm: CareerScreen.ViewModel())
}
