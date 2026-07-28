//
//  Paywall+SkipButton.swift
//  YouHQ
//
//  Created by Ryan Token on 2/22/26.
//

import SwiftUI

extension Paywall {
	struct SkipButton: View {
		let title: String
		let onComplete: (() -> Void)?

		init(title: String = "Skip", onComplete: (() -> Void)?) {
			self.title = title
			self.onComplete = onComplete
		}

		var body: some View {
			Button {
				onComplete?()
			} label: {
				HQText(title)
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
