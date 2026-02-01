//
//  ExternalLinkIndicator.swift
//  YouHQ
//
//  Created by Ryan Token on 1/31/26.
//

import SwiftUI

struct ExternalLinkIndicator: View {
    var body: some View {
		Image(systemName: "arrow.up.forward")
			.foregroundStyle(.secondary)
			.font(.caption)
			.fontWeight(.semibold)
    }
}

#Preview {
    ExternalLinkIndicator()
}
