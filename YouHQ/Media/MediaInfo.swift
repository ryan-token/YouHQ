//
//  MediaInfo.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct MediaInfo: View {
	let vm: MediaScreen.ViewModel

	var body: some View {
		ForEach(vm.serviceProviderViewModel.serviceProviders) { serviceProvider in
			ServiceProviderRow(serviceProvider: serviceProvider, vm: vm)
		}

		ForEach(vm.subscriptionViewModel.subscriptions) { subscription in
			SubscriptionRow(subscription: subscription, vm: vm)
		}

		ForEach(vm.deviceViewModel.devices) { device in
			DeviceRow(device: device, vm: vm)
		}

		ForEach(vm.otherViewModel.others) { other in
			OtherRow(other: other, vm: vm)
		}

		AddMoreButton(vm: vm)
	}
}

#Preview {
	MediaInfo(vm: MediaScreen.ViewModel())
}
