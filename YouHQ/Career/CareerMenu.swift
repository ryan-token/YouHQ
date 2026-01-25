//
//  CareerMenu.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct CareerMenu: View {
	let vm: CareerScreen.ViewModel

	var body: some View {
		Button {
			vm.showAddJobSheet()
		} label: {
			Label("Add Job", systemImage: "briefcase.fill")
		}

		Button {
			vm.showAddOtherSheet()
		} label: {
			Label("Add Other", systemImage: "ellipsis.circle.fill")
		}
	}
}
