//
//  YouHQTests.swift
//  YouHQTests
//
//  Created by Ryan Token on 2/21/26.
//

import Dependencies
import DependenciesTestSupport
import Foundation
import SQLiteData
import Testing

@testable import YouHQ

/// Base suite that bootstraps an in-memory database for every nested suite.
/// All test suites should be declared as extensions on this type so they
/// automatically inherit the `.serialized` and `.dependencies` traits.
@Suite(
	.serialized,
	.dependencies {
		$0.uuid = .incrementing
		$0.date = .constant(Date(timeIntervalSince1970: 1_000_000))
		try $0.bootstrapDatabase()
	}
)
struct YouHQTests {}
