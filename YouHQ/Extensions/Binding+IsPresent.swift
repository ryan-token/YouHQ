//
//  Binding+IsPresent.swift
//  YouHQ
//
//  Created by Ryan Token on 5/20/26.
//

import SwiftUI

extension Binding {
	/// Bridges a `Binding<T?>` to a `Binding<Bool>` for use as the `isPresented:`
	/// argument of `.alert(_:isPresented:presenting:)` and similar APIs.
	/// Writing `false` clears the wrapped optional.
	func isPresent<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
		Binding<Bool>(
			get: { wrappedValue != nil },
			set: { if !$0 { wrappedValue = nil } }
		)
	}
}
