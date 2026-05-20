//
//  OnboardingBackButton.swift
//  YouHQ
//
//  Created by Ryan Token on 5/20/26.
//

import SwiftUI

struct OnboardingBackButton: View {
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		Button("Back", systemImage: "chevron.left") {
			dismiss()
		}
		.labelStyle(.iconOnly)
		.font(.title2.weight(.medium))
		#if !os(visionOS)
			.buttonStyle(.glass)
		#endif
	}
}

#Preview {
	OnboardingBackButton()
}
