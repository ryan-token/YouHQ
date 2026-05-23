//
//  PhotoAssetLink.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import Foundation
import SQLiteData

/// Identifies which entity an image asset is linked to.
/// Used to fetch, create, and delete photo assets for various entity types.
enum PhotoAssetLink {
	case residence(Residence)
	case vehicle(Vehicle)
	case insurancePolicy(InsurancePolicy)
	case maintenanceItem(MaintenanceItem)
	case other(Other)

	// MARK: - Public API

	func fetchImageData(in database: Database) throws -> Data? {
		try existingAsset(in: database)?.imageData
	}

	func updateAsset(in database: Database, imageData: Data?) throws {
		try deleteExistingAsset(in: database)
		guard let imageData else { return }
		guard let profileID = try resolveProfileID(in: database) else { return }
		try Asset.insert {
			makeAssetDraft(profileID: profileID, imageData: imageData)
		}
		.execute(database)
	}

	// MARK: - Private Helpers

	private var entityID: UUID {
		switch self {
		case .residence(let residence): residence.id
		case .vehicle(let vehicle): vehicle.id
		case .insurancePolicy(let policy): policy.id
		case .maintenanceItem(let item): item.id
		case .other(let other): other.id
		}
	}

	private func existingAsset(in database: Database) throws -> Asset? {
		switch self {
		case .residence:
			try Asset.where { $0.residenceID.eq(entityID) }.fetchOne(database)
		case .vehicle:
			try Asset.where { $0.vehicleID.eq(entityID) }.fetchOne(database)
		case .insurancePolicy:
			try Asset.where { $0.insurancePolicyID.eq(entityID) }.fetchOne(
				database
			)
		case .maintenanceItem:
			try Asset.where { $0.maintenanceItemID.eq(entityID) }.fetchOne(
				database
			)
		case .other:
			try Asset.where { $0.otherID.eq(entityID) }.fetchOne(database)
		}
	}

	private func deleteExistingAsset(in database: Database) throws {
		switch self {
		case .residence:
			try Asset.where { $0.residenceID.eq(entityID) }.delete().execute(
				database
			)
		case .vehicle:
			try Asset.where { $0.vehicleID.eq(entityID) }.delete().execute(
				database
			)
		case .insurancePolicy:
			try Asset.where { $0.insurancePolicyID.eq(entityID) }.delete()
				.execute(database)
		case .maintenanceItem:
			try Asset.where { $0.maintenanceItemID.eq(entityID) }.delete()
				.execute(database)
		case .other:
			try Asset.where { $0.otherID.eq(entityID) }.delete().execute(
				database
			)
		}
	}

	private func resolveProfileID(in database: Database) throws -> UUID? {
		switch self {
		case .residence(let residence):
			return residence.profileID
		case .vehicle(let vehicle):
			return vehicle.profileID
		case .insurancePolicy(let policy):
			return policy.profileID
		case .maintenanceItem(let item):
			if let residenceID = item.residenceID {
				return try Residence.find(residenceID).fetchOne(database)?
					.profileID
			}
			if let vehicleID = item.vehicleID {
				return try Vehicle.find(vehicleID).fetchOne(database)?.profileID
			}
			return nil
		case .other(let other):
			return other.profileID
		}
	}

	private func makeAssetDraft(profileID: UUID, imageData: Data) -> Asset.Draft {
		let residenceID: UUID? =
			if case .residence = self { entityID } else { nil }
		let vehicleID: UUID? =
			if case .vehicle = self { entityID } else { nil }
		let insurancePolicyID: UUID? =
			if case .insurancePolicy = self { entityID } else { nil }
		let maintenanceItemID: UUID? =
			if case .maintenanceItem = self { entityID } else { nil }
		let otherID: UUID? = if case .other = self { entityID } else { nil }

		return Asset.Draft(
			id: UUID(),
			profileID: profileID,
			residenceID: residenceID,
			vehicleID: vehicleID,
			insurancePolicyID: insurancePolicyID,
			maintenanceItemID: maintenanceItemID,
			deviceID: nil,
			otherID: otherID,
			imageData: imageData
		)
	}
}
