//
//  IsNotEmpty.swift
//  YouHQ
//
//  Created by Ryan Token on 1/2/26.
//

extension String {
	var isNotEmpty: Bool {
		!self.isEmpty
	}
}

extension Set {
	var isNotEmpty: Bool {
		!self.isEmpty
	}
}
