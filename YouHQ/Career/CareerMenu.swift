//
//  CareerMenu.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct CareerMenu: View {
	let vm: CareerScreen.ViewModel
	let sourceID: String

	init(vm: CareerScreen.ViewModel, sourceID: String = "addButton") {
		self.vm = vm
		self.sourceID = sourceID
	}

	var body: some View {
		PaywalledButton(
			title: "Add Job",
			systemImage: "briefcase.fill",
			currentCount: vm.careerItemsCount,
			threshold: Constants.paywallCoreItemsThreshold
		) {
			vm.showAddJobSheet(sourceID: sourceID)
		}

		PaywalledButton(
			title: "Add Other",
			systemImage: "ellipsis.circle.fill",
			currentCount: vm.careerItemsCount,
			threshold: Constants.paywallCoreItemsThreshold
		) {
			vm.showAddOtherSheet(sourceID: sourceID)
		}
	}
}
