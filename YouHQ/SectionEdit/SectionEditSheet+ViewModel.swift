//
//  SectionEditSheet+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 1/10/26.
//

import SwiftUI

protocol SectionEditViewModel: AnyObject, Observable {
	var title: String { get }
	var isValid: Bool { get }
	var deleteConfirmationMessage: String { get }
	func save()
	func cancel()
	func delete()
}

extension SectionEditSheet {
	@Observable
	class ViewModel {
		let section: EditableSection
		private let sectionViewModel: any SectionEditViewModel

		var title: String {
			sectionViewModel.title
		}

		var isValid: Bool {
			sectionViewModel.isValid
		}

		var deleteConfirmationMessage: String {
			sectionViewModel.deleteConfirmationMessage
		}

		let sectionString: String

		init(section: EditableSection) {
			self.section = section

			switch section {
			case .residenceInfo(let residence):
				sectionViewModel = ResidenceInfoEdit.ViewModel(
					residence: residence
				)
				sectionString = "Residence"
			case .utility(let utility, let isNew):
				sectionViewModel = UtilityEdit.ViewModel(
					utility: utility,
					isNew: isNew
				)
				sectionString = "Utility"
			case .insurancePolicy(let policy, let isNew):
				sectionViewModel = InsuranceEdit.ViewModel(
					policy: policy,
					isNew: isNew
				)
				sectionString = "Policy"
			case .maintenanceItem(let item, let isNew):
				sectionViewModel = MaintenanceItemEdit.ViewModel(
					item: item,
					isNew: isNew
				)
				sectionString = "Maintenance Item"
			case .other(let other, let isNew):
				sectionViewModel = OtherEdit.ViewModel(
					other: other,
					isNew: isNew
				)
				sectionString = other.name
			}
		}

		func save() {
			sectionViewModel.save()
		}

		func cancel() {
			sectionViewModel.cancel()
		}

		func delete() {
			sectionViewModel.delete()
		}

		// Type-safe accessors for specific view models
		var residenceViewModel: ResidenceInfoEdit.ViewModel? {
			sectionViewModel as? ResidenceInfoEdit.ViewModel
		}

		var utilityViewModel: UtilityEdit.ViewModel? {
			sectionViewModel as? UtilityEdit.ViewModel
		}

		var insuranceViewModel: InsuranceEdit.ViewModel? {
			sectionViewModel as? InsuranceEdit.ViewModel
		}

		var maintenanceViewModel: MaintenanceItemEdit.ViewModel? {
			sectionViewModel as? MaintenanceItemEdit.ViewModel
		}

		var otherViewModel: OtherEdit.ViewModel? {
			sectionViewModel as? OtherEdit.ViewModel
		}
	}
}
