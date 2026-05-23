//
//  PaywallGradient.swift
//  YouHQ
//
//  Created by Ryan Token on 2/12/26.
//

import SwiftUI

struct PaywallGradient: View {
	@Environment(\.colorScheme) var colorScheme

	var finalGradientColor: Color {
		colorScheme == .light ? .white : .black
	}

	var body: some View {
		LinearGradient(colors: [.black, .indigo, finalGradientColor], startPoint: .top, endPoint: .bottom)
	}
}

#Preview {
	PaywallGradient()
}
