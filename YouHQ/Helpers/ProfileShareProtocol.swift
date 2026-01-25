//
//  ProfileShareProtocol.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import Foundation

protocol ProfileShareProtocol {
	var profile: Profile { get }
	var isShared: Bool { get }
}
