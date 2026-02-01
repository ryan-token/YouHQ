//
//  MediaScreen+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

extension MediaScreen {
	@Observable
	class ViewModel: ProfileSelection {
		@ObservationIgnored
		@FetchAll(ProfileShare.none, animation: .default) var profiles

		@ObservationIgnored
		@AppStorage(.selectedProfileIDKey) var selectedProfileIDString: String = ""

		// Child view models for entity-specific operations
		var deviceViewModel = DeviceViewModel()
		var serviceProviderViewModel = ServiceProviderViewModel()
		var subscriptionViewModel = SubscriptionViewModel()
		var otherViewModel = OtherItemViewModel()

		init() {}

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

		// MARK: PROFILE FUNCTIONS

		func loadProfiles() async {
			_ = await withErrorReporting {
				try await $profiles.load(
					Profile
						.group(by: \.id)
						.leftJoin(SyncMetadata.all) {
							$0.syncMetadataID.eq($1.id)
						}
						.select {
							ProfileShare.Columns(
								profile: $0,
								isShared: $1.isShared.ifnull(false)
							)
						},
					animation: .default
				)
			}
		}

		// MARK: MEDIA DATA FUNCTIONS

		func loadMediaData() async {
			guard let profileID = selectedProfile?.profile.id else { return }
			await loadAllData(for: profileID)
		}

		private func loadAllData(for profileID: UUID) async {
			await deviceViewModel.load(for: profileID)
			await serviceProviderViewModel.load(for: profileID)
			await subscriptionViewModel.load(for: profileID)
			await otherViewModel.loadCategory(for: .media, profileID: profileID)
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
					total += cost
				}
			}

			return total
		}

		// MARK: SHEET PRESENTATION

		func showAddDeviceSheet() {
			guard let profileID = selectedProfile?.profile.id else { return }
			deviceViewModel.draftDevice = deviceViewModel.createDraft(
				for: profileID
			)
			sectionToEdit = .deviceDraft
			isShowingSectionEditSheet = true
		}

		func showAddServiceProviderSheet() {
			guard let profileID = selectedProfile?.profile.id else { return }
			serviceProviderViewModel.draftServiceProvider =
				serviceProviderViewModel.createDraft(for: profileID)
			sectionToEdit = .serviceProviderDraft
			isShowingSectionEditSheet = true
		}

		func showAddSubscriptionSheet() {
			guard let profileID = selectedProfile?.profile.id else { return }
			subscriptionViewModel.draftSubscription =
				subscriptionViewModel.createDraft(for: profileID)
			sectionToEdit = .subscriptionDraft
			isShowingSectionEditSheet = true
		}

		func showAddOtherSheet() {
			guard let profileID = selectedProfile?.profile.id else { return }
			otherViewModel.draftOther = otherViewModel.createCategoryDraft(
				for: .media,
				profileID: profileID
			)
			sectionToEdit = .otherDraft
			isShowingSectionEditSheet = true
		}
	}
}
