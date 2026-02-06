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
						Image(systemName: "square.and.arrow.up")
					}
				}
				.buttonStyle(.plain)
			}
		#endif
	}

	func shareProfileTapped() async {
		guard paywallManager.hasUnlockedPremium else {
			paywallManager.isShowingPaywallSheet = true
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

struct SharedLabel: View {
	@Binding var sharedRecord: SharedRecord?
	let participantsCount: Int

	var body: some View {
		HStack {
			Image(systemName: "network")
			HQText(participantsCount > 0 ? "Shared With \(participantsCount)" : "Shareable")
		}
		.padding(.vertical, 6)
		.padding(.horizontal, 12)
		.background(participantsCount > 0 ? .indigo : .indigo.opacity(0.6))
		.foregroundStyle(.white)
		.clipShape(.capsule)
		#if !os(macOS)
			.modifier(SharePresentationModifier(sharedRecord: $sharedRecord))
		#endif
	}
}

#if !os(macOS)
	struct SharePresentationModifier: ViewModifier {
		@Binding var sharedRecord: SharedRecord?

		func body(content: Content) -> some View {
			if UIDevice.current.userInterfaceIdiom == .phone {
				content.sheet(item: $sharedRecord) { sharedRecord in
					CloudSharingView(sharedRecord: sharedRecord)
				}
			} else {
				content.popover(item: $sharedRecord) { sharedRecord in
					CloudSharingView(sharedRecord: sharedRecord)
				}
			}
		}
	}
#endif

#Preview {
	SharingStatus(for: ProfileShare(profile: Profile.sampleData, isShared: true, metadata: nil))
}
