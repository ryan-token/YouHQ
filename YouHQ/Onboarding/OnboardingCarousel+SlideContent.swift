//
//  OnboardingCarousel+SlideContent.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import SwiftUI

extension OnboardingCarousel {
	struct SlideContent: View {
		/// The smallest screenshot height worth showing. `ViewThatFits` measures against this
		/// ideal height to decide whether the page needs to scroll; when it doesn't, the
		/// screenshot still grows to fill the space available, up to its maximum.
		private static let minimumScreenshotHeight = 150.0
		private static let maximumScreenshotHeight = 525.0

		let screenshot: OnboardingScreenshot
		let colorScheme: ColorScheme

		var body: some View {
			VStack {
				ScalableImage(
					colorScheme == .light ? screenshot.imageNameLight : screenshot.imageNameDark,
					height: nil
				)
				.frame(idealHeight: Self.minimumScreenshotHeight, maxHeight: Self.maximumScreenshotHeight)

				HQText(screenshot.title)
					.font(.title2)
					.bold()

				HQText(screenshot.description)
					.font(.headline)
					.fontWeight(.medium)
			}
			.padding(.horizontal, 8)
			.padding(.bottom, 40)
		}
	}
}
