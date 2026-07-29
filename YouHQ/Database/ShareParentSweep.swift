//
//  ShareParentSweep.swift
//  YouHQ
//
//  Created by Ryan Token on 7/28/26.
//

import CloudKit
import Dependencies
import Foundation
import SQLiteData

/// Gives records that predate the single-foreign-key schema a CloudKit parent, so the people a
/// profile is shared with can finally see them.
///
/// SQLiteData assigns a parent only to a table with exactly one foreign key, so before that
/// change insurance policies, other items, maintenance items, paint colors and photos were all
/// parentless root records that no share ever included. The migration fixes the schema, but a
/// record already in iCloud keeps its stored metadata until something touches it.
///
/// Touching a row is enough: SQLiteData's update trigger recomputes the parent from the single
/// foreign key and queues an upload. `SET "id" = "id"` is the library's own idiom for this, and
/// is safe because the primary-key trigger only fires when the key actually changes.
///
/// This runs as an ordinary application write rather than in the migration, for the same reason
/// as `LegacyEncryptedFieldSweep`: SQLiteData installs its sync triggers as temporary triggers
/// when the `SyncEngine` is created, which is after migrations, so a migration's writes never
/// reach iCloud.
///
/// It runs on every launch rather than once. A device still on an older version recomputes the
/// parent as `NULL` whenever it edits one of these records, evicting it from the share again, so
/// a one-shot sweep would not hold. The query only matches records that still lack a parent, so
/// repeat runs cost nothing.
///
/// This type can be deleted once every client has run a version containing it.
nonisolated struct ShareParentSweep {
	@Dependency(\.defaultDatabase) var database

	/// Every table the migration reduced to a single `profileID` foreign key.
	private static let tables = singleProfileForeignKeyTables

	/// Tables whose `profileID` was added by the migration and can still arrive empty from a
	/// client on an older version.
	private static let backfilledTables = ["maintenanceItems", "paintColors"]

	/// Re-parents what it can and returns how many records were touched, which is zero on all
	/// but the first run after updating.
	@discardableResult
	func run() async -> Int {
		await withErrorReporting {
			try await database.write { db in
				let profileIDs = try sweepableProfileIDs(db)
				guard !profileIDs.isEmpty else { return 0 }

				var swept = 0
				for table in Self.backfilledTables {
					try backfillProfileID(table: table, profileIDs: profileIDs, db: db)
				}
				for table in Self.tables {
					swept += try reparentRecords(table: table, profileIDs: profileIDs, db: db)
				}
				return swept
			}
		} ?? 0
	}

	/// The profiles whose records this device may re-parent.
	///
	/// Two filters, both of which prevent data loss rather than merely tidying up.
	///
	/// A profile the current user cannot write is skipped because SQLiteData's permission
	/// trigger aborts the whole statement on the first such row, and because pushing one fails
	/// with `permissionFailure`, after which the library deletes the local row.
	///
	/// A profile with no confirmed server record is skipped because re-parenting a child before
	/// its parent exists in iCloud returns a reference violation, and the schema change newly
	/// arms SQLiteData's recovery for that error: with a single cascading foreign key it deletes
	/// the offending row locally and propagates the delete.
	private func sweepableProfileIDs(_ db: Database) throws -> [Profile.ID] {
		try ProfileShare.allWithSyncMetadata
			.fetchAll(db)
			.filter { profile in
				guard profile.metadata?.hasLastKnownServerRecord == true else { return false }
				guard let share = profile.metadata?.share else { return true }
				return share.currentUserParticipant?.permission == .readWrite
					|| share.publicPermission == .readWrite
			}
			.map(\.id)
	}

	/// Resolves `profileID` from the row's own residence or vehicle.
	///
	/// Never a device-wide current profile: multiple profiles ship, and a share recipient holds
	/// the owner's profile alongside their own, so a global fallback would file the owner's
	/// records under a stranger's profile.
	/// Rows resolving to a profile this device may not write are left alone rather than filled,
	/// because writing one would trip SQLiteData's permission trigger and abort the sweep.
	private func backfillProfileID(table: String, profileIDs: [Profile.ID], db: Database) throws {
		for profileID in profileIDs {
			try #sql(
				"""
				UPDATE "\(raw: table)" SET "profileID" = \(bind: profileID)
				WHERE "profileID" IS NULL AND COALESCE(
					(SELECT "profileID" FROM "residences" WHERE "id" = "\(raw: table)"."residenceID"),
					(SELECT "profileID" FROM "vehicles" WHERE "id" = "\(raw: table)"."vehicleID")
				) = \(bind: profileID)
				"""
			)
			.execute(db)
		}
	}

	/// One statement per profile rather than an `IN` list, because SQLiteData does not re-export
	/// GRDB's `StatementArguments` and `#sql` binds one value at a time. Profiles are few.
	private func reparentRecords(table: String, profileIDs: [Profile.ID], db: Database) throws -> Int {
		var swept = 0
		for profileID in profileIDs {
			try #sql(
				"""
				UPDATE "\(raw: table)" SET "id" = "id"
				WHERE "profileID" = \(bind: profileID)
				AND "id" NOT IN (
					SELECT "recordPrimaryKey" FROM "\(raw: SyncMetadata.tableName)"
					WHERE "recordType" = \(bind: table) AND "parentRecordType" IS NOT NULL
				)
				"""
			)
			.execute(db)
			swept += db.changesCount
		}
		return swept
	}
}
