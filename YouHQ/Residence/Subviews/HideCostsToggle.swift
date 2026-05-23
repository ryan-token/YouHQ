//
//  HideCostsToggle.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct HideCostsToggle: View {
	@Binding var hideCosts: Bool

	var body: some View {
		Toggle(isOn: $hideCosts) {
			HQText("Hide Costs")
				.foregroundStyle(.secondary)
				.font(.headline)
		}
		#if os(macOS)
			.padding(.vertical, 4)
		#endif
	}
}

#Preview {
	HideCostsToggle(hideCosts: .constant(true))
}
