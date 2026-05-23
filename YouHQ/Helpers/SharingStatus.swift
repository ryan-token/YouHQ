//
//  SharingStatus.swift
//  YouHQ
//
//  Created by Ryan Token on 1/19/26.
//

import CloudKit
import SQLiteData
import SwiftUI

struct SharingStatus: View {
	@ObservationIgnored
	@Dependency(\.defaultSyncEngine) var syncEngine
	@Environment(PaywallManager.self) private var paywallManager

	let profile: ProfileShare?
	let shouldShowShareButtonIfNotShared: Bool
	let isInsideSheet: Bool

	init(for profile: ProfileShare?, shouldShowShareButtonIfNotShared: Bool = false, isInsideSheet: Bool = false) {
		self.profile = profile
		self.shouldShowShareButtonIfNotShared = shouldShowShareButtonIfNotShared
		self.isInsideSheet = isInsideSheet
	}

	@State private var sharedRecord: SharedRecord?

	private var isShared: Bool {
		profile?.isShared == true
	}

	private var sharedParticipantsCount: Int {
		profile?.participantCount() ?? 0
	}

	private var shouldShowButton: Bool {
		shouldShowShareButtonIfNotShared || isShared
	}

	var body: some View {
		#if os(macOS)
			if isShared {
				SharedLabel(sharedRecord: $sharedRecord, participantsCount: sharedParticipantsCount)
			}
		#else
			if shouldShowButton {
				Button {
					Task {
						await shareProfileTapped()
					}
				} label: {
					if isShared {
						SharedLabel(sharedRecord: $sharedRecord, participantsCount: sharedParticipantsCount)
					} else {
						Label("Share Profile", systemImage: "square.and.arrow.up")
							.labelStyle(.iconOnly)
					}
				}
				.buttonStyle(.plain)
			}
		#endif
	}

	func shareProfileTapped() async {
		guard paywallManager.hasUnlockedPremium else {
			if isInsideSheet {
				paywallManager.showPaywallFromSettings()
			} else {
				paywallManager.showPaywall()
			}
			return
		}

		guard let profile else { return }

		do {
			sharedRecord = try await syncEngine.share(
				record: profile.profile
			) { share in
				share[CKShare.SystemFieldKey.title] = "YouHQ: \(profile.profile.name)"

				#if !os(macOS)
					if let image = UIImage(named: "AppIcon-256"),
						let imageData = image.pngData()
					{
						share[CKShare.SystemFieldKey.thumbnailImageData] = imageData as CKRecordValue
					}
				#endif
			}
		} catch {
			Analytics.logError(id: .profileShareFailed, message: error.localizedDescription)
			reportIssue(error)
		}
	}
}

#Preview {
	SharingStatus(for: ProfileShare(profile: Profile.sampleData, isShared: true, metadata: nil))
}
