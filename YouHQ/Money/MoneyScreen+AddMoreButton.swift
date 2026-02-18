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
		@Environment(\.sheetNamespace) private var namespace

		var body: some View {
			Menu {
				MoneyMenu(vm: vm, sourceID: "addMoreButton")
			} label: {
				AddMoreButtonLabel(text: "Add More")
			}
			.buttonStyle(.plain)
			.padding(.bottom)
			.matchedTransitionSource(id: "addMoreButton", in: namespace)
		}
	}
}
