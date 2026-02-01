//
//  HideSalariesToggle.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct HideSalariesToggle: View {
	@Binding var hideSalaries: Bool

	var body: some View {
		Toggle(isOn: $hideSalaries) {
			HQText("Hide Salaries")
				.foregroundStyle(.secondary)
				.font(.headline)
		}
		#if os(macOS)
			.padding(.vertical, 4)
		#endif
	}
}

#Preview {
	HideSalariesToggle(hideSalaries: .constant(true))
}
