//
//  MediaMenu.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct MediaMenu: View {
	let vm: MediaScreen.ViewModel

	var body: some View {
		Button {
			vm.showAddServiceProviderSheet()
		} label: {
			Label("Add Service Provider", systemImage: "network")
		}

		Button {
			vm.showAddSubscriptionSheet()
		} label: {
			Label("Add Subscription", systemImage: "rectangle.stack")
		}

		Button {
			vm.showAddDeviceSheet()
		} label: {
			Label("Add Device", systemImage: "desktopcomputer")
		}

		Button {
			vm.showAddOtherSheet()
		} label: {
			Label("Add Other", systemImage: "ellipsis.circle.fill")
		}
	}
}
