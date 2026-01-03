//
//  Double+Currency.swift
//  YouHQ
//
//  Created by Ryan Token on 1/2/26.
//

import Foundation

extension Double {
	var asCost: String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.maximumFractionDigits = 2

		let number = NSNumber(value: self)
		return formatter.string(from: number)!
	}
}
