//
//  TextStoredDouble.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import Foundation
import SQLiteData

/// A `QueryRepresentable` type for the amount columns created as `TEXT`.
///
/// Every money column except `jobs.salaryAmount` was declared `TEXT` in the initial schema, so
/// the `STRICT` tables convert each bound `Double` to its text form on write. SQLiteData reports
/// a type mismatch when such a column is decoded straight into `Double`, so this reads the text
/// and parses it instead.
///
/// Writing still binds a `Double`, leaving SQLite's conversion, what is stored, and what syncs to
/// CloudKit exactly as before. Changing these columns to `REAL` would take new column names,
/// because CloudKit has already deployed the current ones as `STRING` fields.
///
/// Usage:
/// ```swift
/// @Table struct Residence {
///     @Column(as: TextStoredDouble?.self) var monthlyCost: Double?
/// }
/// ```
nonisolated struct TextStoredDouble: QueryBindable, QueryDecodable, QueryRepresentable {
	var queryOutput: Double

	init(queryOutput: Double) {
		self.queryOutput = queryOutput
	}

	var queryBinding: QueryBinding {
		.double(queryOutput)
	}

	/// Unparseable text reads as zero, matching SQLite's own numeric conversion that the
	/// previous direct `Double` decoding relied on.
	init(decoder: inout some QueryDecoder) throws {
		self.queryOutput = Double(try String(decoder: &decoder)) ?? 0
	}
}
