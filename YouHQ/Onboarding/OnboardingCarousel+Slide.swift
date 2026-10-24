//
//  OnboardingCarousel+Slide.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import SwiftUI

extension OnboardingCarousel {
	/// One carousel page. The screenshot shrinks to make room for the text; when even a
	/// small screenshot plus the text can't fit (large Dynamic Type, or a short window such
	/// as iPhone Duo's outer display), the page scrolls instead of clipping its text.
	struct Slide: View {
		let screenshot: OnboardingScreenshot
		let colorScheme: ColorScheme

		var body: some View {
			ViewThatFits(in: .vertical) {
				SlideContent(screenshot: screenshot, colorScheme: colorScheme)

				ScrollView {
					SlideContent(screenshot: screenshot, colorScheme: colorScheme)
				}
				.scrollBounceBehavior(.basedOnSize)
			}
		}
	}
}
