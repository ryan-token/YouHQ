//
//  View+Apply.swift
//  YouHQ
//
//  Created by Ryan Token on 1/3/26.
//

import SwiftUI

extension View {
	func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
}
