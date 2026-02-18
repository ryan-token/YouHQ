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
		@Environment(\.sheetNamespace) private var namespace

		var body: some View {
			Menu {
				ResidenceMenu(vm: vm, includeAddResidence: false, sourceID: "addMoreButton")
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
	ResidenceInfo.AddMoreButton(vm: ResidenceScreen.ViewModel())
}
