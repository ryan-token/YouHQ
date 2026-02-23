//
//  HQText.swift
//  YouHQ
//
//  Created by Ryan Token on 1/31/26.
//

import SwiftUI

struct HQText: View {
	let text: String
	let italic: Bool

	init(_ text: String, italic: Bool = false) {
		self.text = text
		self.italic = italic
	}

	var body: some View {
		Text(text)
			.fontDesign(.rounded)
			#if !os(iOS)
				.if(italic) {
					$0.padding(.leading, 2)
				}
			#endif
			.if(italic) {
				$0.transformEffect(CGAffineTransform(a: 1, b: 0, c: CGFloat(tan(-10 * CGFloat.pi / 180)), d: 1, tx: 0, ty: 0))
			}
	}
}

#Preview {
	HQText("YouHQ Premium")
}
