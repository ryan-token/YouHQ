//
//  InfoSectionContent.swift
//  YouHQ
//
//  Created by Ryan Token on 1/8/26.
//

import SwiftUI

/// The leading-aligned stack of rows inside an `InfoSection` card.
struct InfoSectionContent<Content: View>: View {
	@ViewBuilder let content: Content

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			content
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}
