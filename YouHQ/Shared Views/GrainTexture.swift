//
//  GrainTexture.swift
//  YouHQ
//
//  Created by Ryan Token on 1/10/26.
//

import SwiftUI

struct GrainTexture: View {
	var body: some View {
		Canvas { context, size in
			let dotSize: CGFloat = 3
			let spacing: CGFloat = 9

			for xPosition in stride(from: 0, to: size.width, by: spacing) {
				for yPosition in stride(from: 0, to: size.height, by: spacing) {
					if Double.random(in: 0...1) > 0.5 {
						let rect = CGRect(
							x: xPosition,
							y: yPosition,
							width: dotSize,
							height: dotSize
						)
						let path = Path(ellipseIn: rect)
						context.fill(
							path,
							with: .color(.white.opacity(Double.random(in: 0.3...1.0)))
						)
					}
				}
			}
		}
	}
}
