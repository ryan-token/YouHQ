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
				AddMoreButtonLabel(text: "Add More")
			}
			.buttonStyle(.plain)
			.padding(.bottom)
		}
	}
}
