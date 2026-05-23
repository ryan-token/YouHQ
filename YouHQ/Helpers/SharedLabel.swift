//
//  SharedLabel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/19/26.
//

import CloudKit
import SQLiteData
import SwiftUI

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
