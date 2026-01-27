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
				AddMoreButtonLabel(text: "Add More")
			}
			.buttonStyle(.plain)
			.padding(.bottom)
		}
	}
}

#Preview {
	ResidenceInfo.AddMoreButton(vm: ResidenceScreen.ViewModel())
}
