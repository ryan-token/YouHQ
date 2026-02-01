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

	init(for profile: ProfileShare?, shouldShowShareButtonIfNotShared: Bool = false) {
		self.profile = profile
		self.shouldShowShareButtonIfNotShared = shouldShowShareButtonIfNotShared
	}

	// Sharable CloudKit data that can also drive a sheet to present a share interface
	@State private var sharedRecord: SharedRecord?

	var body: some View {
		if shouldShowShareButtonIfNotShared {
			Button {
				#if !os(macOS)
					Task {
						await shareProfileTapped()
					}
				#endif
			} label: {
				if let profile, profile.isShared {
					SharedLabel(sharedRecord: $sharedRecord)
				} else {
					#if !os(macOS)
						Image(systemName: "square.and.arrow.up")
					#endif
				}
			}
			.buttonStyle(.plain)
		} else {
			if let profile, profile.isShared {
				Button {
					#if !os(macOS)
						Task {
							await shareProfileTapped()
						}
					#endif
				} label: {
					SharedLabel(sharedRecord: $sharedRecord)
				}
				.buttonStyle(.plain)
			}
		}
	}

	func shareProfileTapped() async {
		if paywallManager.hasUnlockedPremium {
			if let profile {
				do {
					sharedRecord = try await syncEngine.share(
						record: profile.profile
					) {
						$0[CKShare.SystemFieldKey.title] =
							"\(profile.profile.name) Profile"
						$0[CKShare.SystemFieldKey.thumbnailImageData] = nil
					}
				} catch {
					Analytics.logError(id: .profileShareFailed, message: error.localizedDescription)
					reportIssue(error)
				}
			}
		} else {
			paywallManager.isShowingPaywallSheet = true
		}
	}
}

struct SharedLabel: View {
	@Binding var sharedRecord: SharedRecord?

	var body: some View {
		HStack {
			Image(systemName: "network")
			HQText("Shared")
		}
		.padding(.vertical, 6)
		.padding(.horizontal, 12)
		.background(.blue)
		.foregroundStyle(.white)
		.clipShape(.capsule)

		#if !os(macOS)
			.if(UIDevice.current.userInterfaceIdiom == .phone) {
				$0.sheet(item: $sharedRecord) { sharedRecord in
					CloudSharingView(sharedRecord: sharedRecord)
				}
			}
			.if(UIDevice.current.userInterfaceIdiom == .pad) {
				$0.popover(item: $sharedRecord) { sharedRecord in
					CloudSharingView(sharedRecord: sharedRecord)
				}
			}
		#endif
	}
}

#Preview {
	SharingStatus(for: ProfileShare(profile: Profile.sampleData, isShared: true))
}
