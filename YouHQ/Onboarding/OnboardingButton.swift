//
//  OnboardingButton.swift
//  YouHQ
//
//  Created by Ryan Token on 2/7/26.
//

import SwiftUI

struct OnboardingButton: View {
	let action: () -> Void
	let text: String
	let iconName: String
	let backgroundColor: Color

	var body: some View {
		Button {
			action()
		} label: {
			Label(
				title: { HQText(text) },
				icon: { Image(systemName: iconName) }
			)
			.padding(4)
			.fontWeight(.semibold)
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.buttonStyle(.borderedProminent)
		.tint(backgroundColor)
		.foregroundStyle(.white)
	}
}

#Preview {
	OnboardingButton(action: {}, text: "Add Residence", iconName: "house.fill", backgroundColor: .indigo)
}
