//
//  Paywall+SkipButton.swift
//  YouHQ
//
//  Created by Ryan Token on 2/22/26.
//

import SwiftUI

extension Paywall {
	struct SkipButton: View {
		let onComplete: (() -> Void)?

		var body: some View {
			Button {
				onComplete?()
			} label: {
				HQText("Skip")
					.foregroundStyle(.white.opacity(0.7))
					.fontWeight(.medium)
					.padding(.horizontal)
			}
			.buttonStyle(.bordered)
			.controlSize(.regular)
			.overlay {
				Capsule()
					.stroke(.white.opacity(0.8), lineWidth: 1)
			}
			.padding(.top, 8)
			.padding(.bottom, 2)
		}
	}
}

#Preview {
	Paywall.SkipButton(onComplete: {})
}
