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

		init(
			section: EditableSection,
			draftUtility: Binding<Utility?>,
			draftInsurancePolicy: Binding<InsurancePolicy?>,
			draftMaintenanceItem: Binding<MaintenanceItem?>,
			draftOther: Binding<Other?>,
			draftPaintColor: Binding<RoomPaintColor?>
		) {
			self.section = section

			switch section {
			case .residenceInfo(let residence):
				sectionViewModel = ResidenceInfoEdit.ViewModel(
					residence: residence
				)
				sectionString = "Residence"
			case .utility(let utility):
				sectionViewModel = UtilityEdit.ViewModel(
					utility: utility,
					isNew: false
				)
				sectionString = "Utility"
			case .utilityDraft:
				guard let utility = draftUtility.wrappedValue else {
					fatalError(
						"Draft utility must exist for .utilityDraft case"
					)
				}
				sectionViewModel = UtilityEdit.ViewModel(
					utility: utility,
					isNew: true
				)
				sectionString = "Utility"
			case .insurancePolicy(let policy):
				sectionViewModel = InsuranceEdit.ViewModel(
					policy: policy,
					isNew: false
				)
				sectionString = "Policy"
			case .insurancePolicyDraft:
				guard let policy = draftInsurancePolicy.wrappedValue else {
					fatalError(
						"Draft policy must exist for .insurancePolicyDraft case"
					)
				}
				sectionViewModel = InsuranceEdit.ViewModel(
					policy: policy,
					isNew: true
				)
				sectionString = "Policy"
			case .maintenanceItem(let item):
				sectionViewModel = MaintenanceItemEdit.ViewModel(
					item: item,
					isNew: false
				)
				sectionString = "Maintenance Item"
			case .maintenanceItemDraft:
				guard let item = draftMaintenanceItem.wrappedValue else {
					fatalError(
						"Draft maintenance item must exist for .maintenanceItemDraft case"
					)
				}
				sectionViewModel = MaintenanceItemEdit.ViewModel(
					item: item,
					isNew: true
				)
				sectionString = "Maintenance Item"
			case .paintColor(let paintColor):
				sectionViewModel = PaintColorEdit.ViewModel(
					paintColor: paintColor,
					isNew: false
				)
				sectionString = "Paint Color"
			case .paintColorDraft:
				guard let paintColor = draftPaintColor.wrappedValue else {
					fatalError(
						"Draft paint color must exist for .paintColorDraft case"
					)
				}
				sectionViewModel = PaintColorEdit.ViewModel(
					paintColor: paintColor,
					isNew: true
				)
				sectionString = "Paint Color"
			case .other(let other):
				sectionViewModel = OtherEdit.ViewModel(
					other: other,
					isNew: false
				)
				sectionString = other.name
			case .otherDraft:
				guard let other = draftOther.wrappedValue else {
					fatalError("Draft other must exist for .otherDraft case")
				}
				sectionViewModel = OtherEdit.ViewModel(
					other: other,
					isNew: true
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

		var paintColorViewModel: PaintColorEdit.ViewModel? {
			sectionViewModel as? PaintColorEdit.ViewModel
		}

		var otherViewModel: OtherEdit.ViewModel? {
			sectionViewModel as? OtherEdit.ViewModel
		}
	}
}
