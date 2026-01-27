//
//  MediaScreen.swift
//  YouHQ
//
//  Created by Ryan Token on 12/29/25.
//

import SQLiteData
import SwiftUI

struct MediaScreen: View {
	@State private var vm = ViewModel()
	@AppStorage("hideMediaCosts") private var hideMediaCosts = false

	var body: some View {
		List {
			Group {
				if hasNoData {
					NoMediaView(vm: vm)
				} else {
					HideCostsToggle(hideCosts: $hideMediaCosts)

					if vm.totalMonthlyCost > 0 {
						MonthlyCostRow(
							totalCost: vm.totalMonthlyCost,
							serviceProviders: vm.serviceProviderViewModel.serviceProviders,
							subscriptions: vm.subscriptionViewModel.subscriptions,
							blurred: hideMediaCosts
						)
					}

					MediaInfo(vm: vm, hideCosts: hideMediaCosts)
				}
			}
			.listRowSeparator(.hidden)
			.listRowBackground(Color.clear)
		}
		.animation(.default, value: vm.deviceViewModel.devices.count)
		.animation(.default, value: vm.serviceProviderViewModel.serviceProviders.count)
		.animation(.default, value: vm.subscriptionViewModel.subscriptions.count)
		.animation(.default, value: vm.otherViewModel.others.count)
		.navigationTitle("Media")
		.navigationTitle("Career")
		#if !os(macOS)
			.navigationBarTitleDisplayMode(.inline)
		#endif
		.toolbar { Toolbar(vm: vm) }
		.contentMargins(.top, 0)
		.scrollContentBackground(.hidden)
		.task {
			await vm.loadProfiles()
			await vm.loadMediaData()
		}
		.onChange(of: vm.profiles.count) {
			Task { await vm.loadMediaData() }
		}
		.sheet(isPresented: $vm.isShowingSectionEditSheet) {
			if let sectionToEdit = vm.sectionToEdit {
				SectionEditSheet(
					section: sectionToEdit,
					draftOther: $vm.otherViewModel.draftOther,
					draftDevice: $vm.deviceViewModel.draftDevice,
					draftServiceProvider: $vm.serviceProviderViewModel.draftServiceProvider,
					draftSubscription: $vm.subscriptionViewModel.draftSubscription
				)
			}
		}
		#if !os(visionOS)
			.scrollDismissesKeyboard(.immediately)
		#endif
	}

	var hasNoData: Bool {
		vm.deviceViewModel.devices.isEmpty
			&& vm.serviceProviderViewModel.serviceProviders.isEmpty
			&& vm.subscriptionViewModel.subscriptions.isEmpty
			&& vm.otherViewModel.others.isEmpty
	}
}

#Preview {
	let _ = prepareDependencies { // swiftlint:disable:this redundant_discardable_let
		try? $0.bootstrapDatabase()
		try? $0.defaultDatabase.seed()
	}

	NavigationStack {
		MediaScreen()
	}
}
