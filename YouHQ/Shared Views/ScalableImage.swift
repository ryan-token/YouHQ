//
//  ScalableImage.swift
//  YouHQ
//
//  Created by Ryan Token on 2/7/26.
//

import SwiftUI

struct ScalableImage: View {
	let imageName: String
	let height: CGFloat?

	init(_ imageName: String, height: CGFloat? = 80) {
		self.imageName = imageName
		self.height = height
	}

	var body: some View {
		Image(imageName)
			.resizable()
			.scaledToFit()
			.frame(height: height)
	}
}

#Preview {
	ScalableImage("AppIcon")
}
