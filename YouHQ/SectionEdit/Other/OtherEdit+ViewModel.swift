//
//  OtherEdit+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import SQLiteData
import SwiftUI

extension OtherEdit {
	@Observable
	final class ViewModel: SectionEditViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		let other: Other
		let isNew: Bool

		var name: String
		var otherDescription: String
		var monthlyCost: Double?
		var url: String
		var notes: String
		var photoPicker = PhotoPickerViewModel()

		// Profile switching support
		@ObservationIgnored
		@FetchAll(ProfileShare.none, animation: .default) var profiles
		var currentProfileID: UUID
		var supportsProfileSwitching: Bool { true }
		var itemNameForProfilePicker: String {
			name.isNotEmpty ? name : "this item"
		}

		var title: String {
			isNew ? "Add Other" : "Edit Other"
		}

		var isValid: Bool {
			name.trimmingCharacters(in: .whitespaces).isNotEmpty
		}

		let deleteConfirmationMessage = "Are you sure you want to delete this?"

		init(other: Other, isNew: Bool) {
			self.other = other
			self.isNew = isNew
			self.name = other.name
			self.otherDescription = other.otherDescription
			self.monthlyCost = other.monthlyCost
			self.url = other.url
			self.notes = other.notes
			self.currentProfileID = other.profileID
			loadExistingPhotoData()
		}

		func loadProfiles() async {
			await ProfileShare.reload(into: $profiles)
		}

		func save() {
			do {
				try database.write { db in
					if isNew {
						// Insert new record
						try Other.insert {
							Other.Draft(
								id: other.id,
								profileID: currentProfileID,
								residenceID: other.residenceID,
								vehicleID: other.vehicleID,
								category: other.category,
								name: name,
								otherDescription: otherDescription,
								monthlyCost: monthlyCost,
								backgroundColor: other.backgroundColor,
								url: url,
								notes: notes
							)
						}
						.execute(db)
						// Send appropriate analytics signal based on category
						switch other.category {
						case .homes:
							Analytics.sendSignal(.residenceOtherCreated)
						case .vehicles:
							Analytics.sendSignal(.vehicleOtherCreated)
						case .money:
							Analytics.sendSignal(.moneyOtherCreated)
						case .media:
							Analytics.sendSignal(.moneyOtherCreated)
						case .career:
							Analytics.sendSignal(.careerOtherCreated)
						default:
							break
						}
					} else {
						// Update existing record
						try Other.find(other.id)
							.update {
								$0.profileID = currentProfileID
								$0.name = name
								$0.otherDescription = otherDescription
								$0.monthlyCost = monthlyCost
								$0.url = url
								$0.notes = notes
							}
							.execute(db)
					}

					try photoPicker.updateAsset(in: db, link: .other(other))
				}
			} catch {
				Analytics.logError(id: .otherSaveFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}

		func cancel() {
			// Draft items don't need cleanup since they're never in DB
		}

		func delete() {
			do {
				try database.write { db in
					try Other.find(other.id)
						.delete()
						.execute(db)
				}
				// Send appropriate analytics signal based on category
				switch other.category {
				case .homes:
					Analytics.sendSignal(.residenceOtherDeleted)
				case .vehicles:
					Analytics.sendSignal(.vehicleOtherDeleted)
				case .money:
					Analytics.sendSignal(.moneyOtherDeleted)
				case .media:
					Analytics.sendSignal(.moneyOtherDeleted)
				case .career:
					Analytics.sendSignal(.careerOtherDeleted)
				default:
					break
				}
			} catch {
				Analytics.logError(id: .otherDeleteFailed, message: error.localizedDescription)
				reportIssue(error)
			}
		}

		private func loadExistingPhotoData() {
			withErrorReporting {
				try database.read { db in
					try photoPicker.loadExistingPhotoData(
						in: db,
						link: .other(other)
					)
				}
			}
		}
	}
}
