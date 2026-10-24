//
//  CostLineItem.swift
//  YouHQ
//
//  Created by Ryan Token on 1/12/26.
//

import Foundation

/// One labeled amount in a `CostBreakdownView`, identified by the record it came from.
struct CostLineItem: Identifiable {
	let id: UUID
	let label: String
	let cost: Double
}
