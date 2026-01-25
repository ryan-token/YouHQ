//
//  MediaInfo.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct MediaInfo: View {
	@Bindable var vm: MediaScreen.ViewModel
	let hideCosts: Bool

	var body: some View {
		ForEach(vm.serviceProviderViewModel.serviceProviders) { serviceProvider in
			ServiceProviderSection(
				serviceProvider: serviceProvider,
				hideCosts: hideCosts,
				onColorChange: { newColor in
					vm.serviceProviderViewModel.updateBackgroundColor(
						newColor,
						for: serviceProvider
					)
				},
				onTap: {
					vm.sectionToEdit = .serviceProvider(serviceProvider)
					vm.isShowingSectionEditSheet = true
				}
			)
			.swipeActions(edge: .trailing, allowsFullSwipe: true) {
				Button(role: .destructive) {
					vm.serviceProviderViewModel.delete(serviceProvider)
				} label: {
					Label("Delete", systemImage: "trash")
				}
			}
		}

		ForEach(vm.subscriptionViewModel.subscriptions) { subscription in
			SubscriptionSection(
				subscription: subscription,
				hideCosts: hideCosts,
				onColorChange: { newColor in
					vm.subscriptionViewModel.updateBackgroundColor(
						newColor,
						for: subscription
					)
				},
				onTap: {
					vm.sectionToEdit = .subscription(subscription)
					vm.isShowingSectionEditSheet = true
				}
			)
			.swipeActions(edge: .trailing, allowsFullSwipe: true) {
				Button(role: .destructive) {
					vm.subscriptionViewModel.delete(subscription)
				} label: {
					Label("Delete", systemImage: "trash")
				}
			}
		}

		ForEach(vm.deviceViewModel.devices) { device in
			DeviceSection(
				device: device,
				onColorChange: { newColor in
					vm.deviceViewModel.updateBackgroundColor(
						newColor,
						for: device
					)
				},
				onTap: {
					vm.sectionToEdit = .device(device)
					vm.isShowingSectionEditSheet = true
				}
			)
			.swipeActions(edge: .trailing, allowsFullSwipe: true) {
				Button(role: .destructive) {
					vm.deviceViewModel.delete(device)
				} label: {
					Label("Delete", systemImage: "trash")
				}
			}
		}

		ForEach(vm.otherViewModel.others) { other in
			OtherSection(
				other: other,
				hideCosts: hideCosts,
				onColorChange: { newColor in
					vm.otherViewModel.updateBackgroundColor(
						newColor,
						for: other
					)
				},
				onTap: {
					vm.sectionToEdit = .other(other)
					vm.isShowingSectionEditSheet = true
				}
			)
			.swipeActions(edge: .trailing, allowsFullSwipe: true) {
				Button(role: .destructive) {
					vm.otherViewModel.delete(other)
				} label: {
					Label("Delete", systemImage: "trash")
				}
			}
		}

		AddMoreButton(vm: vm)
	}
}

#Preview {
	MediaInfo(vm: MediaScreen.ViewModel(), hideCosts: false)
}
