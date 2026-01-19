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
			loadExistingPhotoData()
		}

		func save() {
			withErrorReporting {
				try database.write { db in
					if isNew {
						// Insert new record
						try Other.insert {
							Other.Draft(
								id: other.id,
								profileID: other.profileID,
								residenceID: other.residenceID,
								name: name,
								otherDescription: otherDescription,
								monthlyCost: monthlyCost,
								backgroundColor: other.backgroundColor,
								url: url,
								notes: notes
							)
						}
						.execute(db)
					} else {
						// Update existing record
						try Other.find(other.id)
							.update {
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
			}
		}

		func cancel() {
			// Draft items don't need cleanup since they're never in DB
		}

		func delete() {
			withErrorReporting {
				try database.write { db in
					try Other.find(other.id)
						.delete()
						.execute(db)
				}
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
