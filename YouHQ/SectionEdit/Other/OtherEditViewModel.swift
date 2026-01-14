//
//  OtherEditViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import SQLiteData
import SwiftUI

@Observable
final class OtherEditViewModel: SectionEditViewModel {
	@ObservationIgnored
	@Dependency(\.defaultDatabase) var database

	let other: Other
	let isNew: Bool

	var name: String
	var otherDescription: String
	var monthlyCost: Double?
	var url: String
	var notes: String

	var title: String {
		isNew ? "Add Other" : "Edit Other"
	}

	var isValid: Bool {
		name.trimmingCharacters(in: .whitespaces).isNotEmpty
	}

	init(other: Other, isNew: Bool) {
		self.other = other
		self.isNew = isNew
		self.name = other.name
		self.otherDescription = other.otherDescription
		self.monthlyCost = other.monthlyCost
		self.url = other.url
		self.notes = other.notes
	}

	func save() {
		withErrorReporting {
			try database.write { db in
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
		}
	}

	func cancel() {
		if isNew {
			deleteOther()
		}
	}

	private func deleteOther() {
		withErrorReporting {
			try database.write { db in
				try Other.find(other.id)
					.delete()
					.execute(db)
			}
		}
	}
}
