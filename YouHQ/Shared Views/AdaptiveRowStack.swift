//
//  AdaptiveRowStack.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import SwiftUI

/// Lays out a label and its value side by side, stacking them vertically at accessibility text
/// sizes so long values aren't squeezed into a sliver beside their label.
///
/// `AnyLayout` switches the arrangement without changing the children's identity, so text
/// selection and other row state survive a Dynamic Type change.
struct AdaptiveRowStack<Content: View>: View {
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize

	var alignment: VerticalAlignment = .center
	@ViewBuilder let content: Content

	var body: some View {
		let layout =
			dynamicTypeSize.isAccessibilitySize
			? AnyLayout(VStackLayout(alignment: .leading))
			: AnyLayout(HStackLayout(alignment: alignment))

		layout {
			content
		}
	}
}

#Preview {
	AdaptiveRowStack(alignment: .top) {
		HQText("Full address:")
			.font(.headline)
		HQText("123 Main St, Springfield, IL 62701")
	}
	.dynamicTypeSize(.accessibility2)
	.padding()
}
