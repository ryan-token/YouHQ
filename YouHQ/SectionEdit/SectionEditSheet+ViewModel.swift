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
				sectionViewModel = ResidenceInfoEditViewModel(
					residence: residence
				)
				sectionString = "Residence"
			case .utility(let utility, let isNew):
				sectionViewModel = UtilityEditViewModel(
					utility: utility,
					isNew: isNew
				)
				sectionString = "Utility"
			case .insurancePolicy(let policy, let isNew):
				sectionViewModel = InsuranceEditViewModel(
					policy: policy,
					isNew: isNew
				)
				sectionString = "Policy"
			case .maintenanceItem(let item, let isNew):
				sectionViewModel = MaintenanceItemEditViewModel(
					item: item,
					isNew: isNew
				)
				sectionString = "Maintenance Item"
			case .other(let other, let isNew):
				sectionViewModel = OtherEditViewModel(
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
		var residenceViewModel: ResidenceInfoEditViewModel? {
			sectionViewModel as? ResidenceInfoEditViewModel
		}

		var utilityViewModel: UtilityEditViewModel? {
			sectionViewModel as? UtilityEditViewModel
		}

		var insuranceViewModel: InsuranceEditViewModel? {
			sectionViewModel as? InsuranceEditViewModel
		}

		var maintenanceViewModel: MaintenanceItemEditViewModel? {
			sectionViewModel as? MaintenanceItemEditViewModel
		}

		var otherViewModel: OtherEditViewModel? {
			sectionViewModel as? OtherEditViewModel
		}
	}
}
