//
//  IsNotEmpty.swift
//  YouHQ
//
//  Created by Ryan Token on 1/2/26.
//

extension String {
	nonisolated var isNotEmpty: Bool {
		!self.isEmpty
	}
}

extension Array {
	nonisolated var isNotEmpty: Bool {
		!self.isEmpty
	}
}

extension Set {
	nonisolated var isNotEmpty: Bool {
		!self.isEmpty
	}
}
