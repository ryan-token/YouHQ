//
//  Optional+OrNow.swift
//  YouHQ
//
//  Created by Ryan Token on 10/23/26.
//

import Foundation

extension Optional where Wrapped == Date {
	/// The date, or the current date when unset. Writing always stores the new date.
	///
	/// A key path gives `DatePicker` a stable binding (`$date.orNow`) instead of a
	/// `Binding(get:set:)` rebuilt on every body evaluation.
	var orNow: Date {
		get { self ?? .now }
		set { self = newValue }
	}
}
