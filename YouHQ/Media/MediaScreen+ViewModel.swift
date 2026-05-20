//
//  MediaScreen+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import Sharing
import SQLiteData
import SwiftUI

extension MediaScreen {
	@Observable
	class ViewModel: ProfileSelection {
		@ObservationIgnored
		@FetchAll(ProfileShare.none, animation: .default) var profiles

		@ObservationIgnored
		@Shared(.appStorage(.selectedProfileIDKey)) var selectedProfileIDString = ""

		// Child view models for entity-specific operations
		var deviceViewModel = DeviceViewModel()
		var serviceProviderViewModel = ServiceProviderViewModel()
		var subscriptionViewModel = SubscriptionViewModel()
		var otherViewModel = OtherItemViewModel()

		init() {}

		func setSelectedProfileIDString(_ value: String) {
			$selectedProfileIDString.withLock { $0 = value }
		}

		var selectedProfile: ProfileShare? {
			getSelectedProfile()
		}

		var mediaItemsCount: Int {
			let devicesCount = deviceViewModel.devices.count
			let serviceProvidersCount = serviceProviderViewModel.serviceProviders.count
			let subscriptionsCount = subscriptionViewModel.subscriptions.count
			let otherCount = otherViewModel.others.count
			return devicesCount + serviceProvidersCount + subscriptionsCount + otherCount
		}

		var isShowingSectionEditSheet = false
		var sectionToEdit: EditableSection?
		var sheetTransitionSourceID: String = "addButton"

		// MARK: PROFILE FUNCTIONS

		func loadProfiles() async {
			_ = await withErrorReporting {
				try await $profiles.load(ProfileShare.allWithSyncMetadata, animation: .default)
			}
		}

		// MARK: MEDIA DATA FUNCTIONS

		func loadMediaData() async {
			guard let profileID = selectedProfile?.profile.id else { return }
			await loadAllData(for: profileID)
		}

		private func loadAllData(for profileID: UUID) async {
			async let devices: Void = deviceViewModel.load(for: profileID)
			async let providers: Void = serviceProviderViewModel.load(for: profileID)
			async let subscriptions: Void = subscriptionViewModel.load(for: profileID)
			async let others: Void = otherViewModel.loadCategory(for: .media, profileID: profileID)
			_ = await (devices, providers, subscriptions, others)
		}

		// MARK: MONTHLY COST CALCULATION

		var totalMonthlyCost: Double {
			var total: Double = 0

			// Add service provider costs
			for serviceProvider in serviceProviderViewModel.serviceProviders {
				if let cost = serviceProvider.monthlyCost {
					total += cost
				}
			}

			// Add subscription costs (only active subscriptions)
			for subscription in subscriptionViewModel.subscriptions {
				if subscription.isActive, let cost = subscription.monthlyCost {
					// Convert annual costs to monthly equivalent
					let monthlyCost = subscription.billingCycle == .annual ? cost / 12 : cost
					total += monthlyCost
				}
			}

			return total
		}

		// MARK: SHEET PRESENTATION

		func showAddDeviceSheet(sourceID: String = "addButton") {
			guard let profileID = selectedProfile?.profile.id else { return }
			sectionToEdit = .deviceDraft(deviceViewModel.createDraft(for: profileID))
			sheetTransitionSourceID = sourceID
			isShowingSectionEditSheet = true
		}

		func showAddServiceProviderSheet(sourceID: String = "addButton") {
			guard let profileID = selectedProfile?.profile.id else { return }
			sectionToEdit = .serviceProviderDraft(serviceProviderViewModel.createDraft(for: profileID))
			sheetTransitionSourceID = sourceID
			isShowingSectionEditSheet = true
		}

		func showAddSubscriptionSheet(sourceID: String = "addButton") {
			guard let profileID = selectedProfile?.profile.id else { return }
			sectionToEdit = .subscriptionDraft(subscriptionViewModel.createDraft(for: profileID))
			sheetTransitionSourceID = sourceID
			isShowingSectionEditSheet = true
		}

		func showAddOtherSheet(sourceID: String = "addButton") {
			guard let profileID = selectedProfile?.profile.id else { return }
			sectionToEdit = .otherDraft(
				otherViewModel.createCategoryDraft(for: .media, profileID: profileID)
			)
			sheetTransitionSourceID = sourceID
			isShowingSectionEditSheet = true
		}
	}
}
